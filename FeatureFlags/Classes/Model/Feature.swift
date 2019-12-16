//
//  Feature.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct Feature {
    
    // MARK: Type defintions
    public typealias Name = FeatureName
    
    // MARK: State
    public let name: Name
    internal var enabled: Bool
    internal let detailText: String?
    public let type: FeatureType
    internal var isDevelopment: Bool
    internal var testVariationAssignment: Double
    internal var testBiases: [Percentage]
    internal let testVariations: [TestVariation]
    internal let labels: [String?]
    internal var testVariationOverride: TestVariation?
    /// Whether an unlockable feature is unlocked or not.
    internal var unlocked: Bool?
    
    /// Syntactic sugar for retrieving a feature by name
    init?(named name: Feature.Name) {
        guard let feature = Feature.named(name) else { return nil }
        self = feature
    }
    
    init(name: Name, description: String? = nil, enabled: Bool, isDevelopment: Bool,
         type: FeatureType, testBiases: [Percentage] = [], testVariations: [TestVariation] = [],
         labels: [String?] = [], unlocked: Bool?) {
        self.name = name
        self.detailText = description
        self.enabled = enabled
        self.type = type
        self.isDevelopment = isDevelopment
        self.testVariationAssignment = Double.random(in: 0..<100)
        self.testBiases = testBiases
        self.testVariations = testVariations
        self.testVariationOverride = nil
        self.labels = labels
        self.unlocked = unlocked
    }
    
    public func label(_ testVariation: Test.Variation) -> String? {
        guard let variationLabel = zip(testVariations, labels).first(where: { $0.0 == testVariation })?.1,
            enabled else {
            return nil
        }
        return variationLabel
    }
    
    public static func isEnabled(_ featureName: Feature.Name, isDevelopment: Bool = false) -> Bool {
        guard let feature = named(featureName) else { return false }
        return feature.isEnabled(isDevelopment: isDevelopment)
    }
    
    public func isTestVariation(_ variation: TestVariation) -> Bool {
        guard enabled else { return variation == .disabled }
        return testVariation() == variation
    }
    
    public static func isTestVariation(feature featureName: Feature.Name, variation: Test.Variation) -> Bool {
        guard let feature = named(featureName) else { return false }
        return feature.isTestVariation(variation)
    }
    
    public func isEnabled(isDevelopment: Bool = false) -> Bool {
        switch type {
        case .featureTest(.featureFlagAB):
            return testVariation() == .enabled // When disabled the test variation will be set to .disabled
        default:
            guard !isDevelopment && !self.isDevelopment else {
                #if DEBUG
                return enabled
                #else
                guard FeatureFlags.isDevelopment else { return false }
                return enabled
                #endif
            }
            return enabled
        }
    }
    
    /// Removes the feature from the cache so that the feature's development status will no longer be persisted.
    /// You should invoke either `FeatureFlags.refresh(_ completion:)`
    /// or `FeatureFlags.refreshWithData(_ data: completion:)`  following invocation of this method so that the
    /// feature is reloaded from the data source.
    public func isNoLongerUnderDevelopment() {
        FeatureFlags.isNoLongerUnderDevelopment(named: name)
    }
    
    public func isUnlocked() -> Bool {
        guard let unlocked = self.unlocked else { return false }
        return isEnabled() && type == .unlockFlag && unlocked
    }
    
    public static func named(_ featureName: Feature.Name) -> Feature? {
        guard let features = FeatureFlags.configuration else { return nil }
        return features.first(where: { $0.name == featureName })
    }
    
    /// Allows the developer to programmatically enable or disable the feature flag.
    /// Note: That programmatic changes to enabled state are not persisted so this
    /// value will only persist until a refresh from configuration occurs.
    internal mutating func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }
    
    /// Allows the developer to programmatically lock or unlock the feature.
    /// Note: Unlike with the `enabled` flag, programmatic changes are persisted.
    /// Ordinarily changes to features are overridden by remote config which has
    /// precedence but here programmatic changes have precedence.
    internal mutating func setUnlocked(_ unlocked: Bool = true) {
        self.unlocked = unlocked
        if var cachedFeatures = FeatureFlags.loadCachedConfiguration(),
            let idx = cachedFeatures.firstIndex(where: { $0.name == self.name }) {
            var cachedFeature = cachedFeatures[idx]
            cachedFeature.unlocked = unlocked
            cachedFeatures.remove(at: idx)
            cachedFeatures.append(cachedFeature)
            FeatureFlags.cacheConfiguration(cachedFeatures)
        } else {
            FeatureFlags.cacheConfiguration([self])
        }
        if var currentFeatures = FeatureFlags.configuration,
            let idx = currentFeatures.firstIndex(where: { $0.name == self.name }) {
            var currentFeature = currentFeatures[idx]
            currentFeature.unlocked = unlocked
            currentFeatures.remove(at: idx)
            currentFeatures.append(currentFeature)
            FeatureFlags.configuration = currentFeatures
        }
    }
    
    /// Convenience method for locking an unlock flag.
    @discardableResult
    public mutating func lock() -> Bool {
        setUnlocked(false)
        return !isUnlocked()
    }
    
    /// Convenience method for unlocking an unlock flag.
    @discardableResult
    public mutating func unlock() -> Bool {
        setUnlocked(true)
        return isUnlocked()
    }
    
    /// Allows the developer to programmatically set the variation.
    /// Note: That programmatic changes to variation state are not persisted so this
    /// value will only persist until a refresh from configuration occurs.
    internal mutating func setTestVariation(_ testVariation: Test.Variation) {
        self.testVariationOverride = testVariation
    }
    
    func testBias(_ testVariation: Test.Variation) -> Percentage? {
        guard enabled else { return Percentage.min }
        guard let testBiasForVariation = zip(testVariations, testBiases).first(where: { pair in
            let currentTestVariation = pair.0
            return currentTestVariation == testVariation
        }) else {
            // If we have ended up here then checks which ensure testVariations and testBiases array count
            // equality have been bypassed.
            assertionFailure("A test variation should always have a bias.")
            return nil
        }
        return testBiasForVariation.1
    }
    
    public func testVariation() -> Test.Variation {
        if let testVariationOverride = self.testVariationOverride {
            return testVariationOverride
        }
        guard enabled else { return .disabled }
        var lowerBound = Percentage.min.rawValue
        var previousLowerBound: Double?
        var previousVariation: (TestVariation, Percentage)?
        for variation in zip(testVariations, testBiases) {
            let upperBound = lowerBound + variation.1.rawValue
            let range = lowerBound..<upperBound
            if range.contains(testVariationAssignment) {
                return variation.0
            }
            previousLowerBound = lowerBound
            previousVariation = variation
            lowerBound = upperBound
        }
        // Handle special case where the upper bound is 100.0 which in theory should not occur since
        // numbers are generated in the range: [0.0, 100.0)
        if let variation = previousVariation, let lowerBound = previousLowerBound {
            let upperBound = lowerBound + variation.1.rawValue
            if upperBound == 100.0 {
                let range = lowerBound...upperBound
                if range.contains(testVariationAssignment) {
                    return variation.0
                }
            }
        }
        assertionFailure("A feature must always be categorizable into a test variation.")
        return .unassigned
    }

}

extension Feature: CustomStringConvertible {
    public var description: String {
        var result = "Feature: \(self.name)"
        result += "\nEnabled: \(self.isEnabled())"
        if type == .unlockFlag {
            result += "\nUnlocked: \(self.isUnlocked())"
        }
        let testVariationsStr = zip(testVariations, testBiases).map { testVariation, testBias in
            return "\(testVariation) (\(testBias))"
            }.joined(separator: ", ")
        result += "\nTest variations: \(testVariationsStr)"
        let testVariationAssignmentStr = String(format: "%.f", testVariationAssignment)
        let assignmentStr = "\(testVariationAssignmentStr)% -> \(testVariation())"
         result += "\nTest variation assignment: \(assignmentStr)"
        return result
    }
}
