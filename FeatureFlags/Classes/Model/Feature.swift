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
    public let type: FeatureType
    internal var isDevelopment: Bool
    internal var testVariationAssignment: Double
    internal var testBiases: [Percentage]
    internal let testVariations: [TestVariation]
    internal let labels: [String?]
    internal var testVariationOverride: TestVariation?
    
    /// Syntactic sugar for retrieving a feature by name
    init?(named name: Feature.Name) {
        guard let feature = Feature.named(name) else { return nil }
        self = feature
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
    
    /// Allows the developer to programmatically set the variation.
    /// Note: That programmatic changes to variation state are not persisted so this
    /// value will only persist until a refresh from configuration occurs.
    internal mutating func setTestVariation(_ testVariation: Test.Variation) {
        self.testVariationOverride = testVariation
    }
    
    func testBias(_ testVariation: Test.Variation) -> Percentage {
        guard enabled else { return Percentage.min }
        guard let testBiasForVariation = zip(testVariations, testBiases).first(where: { pair in
            let currentTestVariation = pair.0
            return currentTestVariation == testVariation
        }) else {
            fatalError("A test variation should always have a bias.")
        }
        return testBiasForVariation.1
    }
    
    public func testVariation() -> TestVariation {
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
        fatalError("A feature must always be categorizable into a test variation.")
    }

}

extension Feature: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case isDevelopment = "development"
        case isEnabled = "enabled"
        case type
        case testBiases = "test-biases"
        case testVariationAssignment = "test-variation-assignment"
        case testVariations = "test-variations"
        case labels = "labels"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(FeatureName.self, forKey: .name)
        let isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled)
        let isDevelopment = try container.decodeIfPresent(Bool.self, forKey: .isDevelopment)
        let testBiases = try container.decodeIfPresent([Percentage].self, forKey: .testBiases)
        self.testVariationAssignment = try container.decodeIfPresent(Double.self, forKey: .testVariationAssignment)
            ?? Double.random(in: 0..<100) // [0.0, 100.0)
        let testVariations = try container.decodeIfPresent([String].self, forKey: .testVariations)
        let defaultTestVariations = [TestVariation(rawValue: "Enabled"), TestVariation(rawValue: "Disabled")]
        if let testVariations = testVariations {
            if testVariations.isEmpty {
                self.isDevelopment = isDevelopment ?? false
                self.enabled = isEnabled ?? false
                self.testVariations = defaultTestVariations
                self.type = .featureFlag
                self.testVariationAssignment = enabled ? 1.0 : 99.0
            } else if testVariations.count == 1, let firstVariation = testVariations.first {
                self.enabled = isEnabled ?? false
                self.isDevelopment = isDevelopment ?? false
                self.testVariations = [TestVariation(rawValue: firstVariation),
                                       TestVariation(rawValue: "!\(firstVariation)")]
                self.type = .featureFlag
            } else if testVariations.count == 2 {
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                let testVariations = testVariations.map({ TestVariation(rawValue: $0) })
                if Feature.testVariationsContains(variationNames: ["enabled", "disabled"], in: testVariations)
                    || Feature.testVariationsContains(variationNames: ["on", "off"], in: testVariations) {
                    self.type = .featureTest(.featureFlagAB)
                    self.testVariations = defaultTestVariations
                } else {
                    self.type = .featureTest(.ab)
                    self.testVariations = testVariations
                }
            } else {
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                self.testVariations = testVariations.map({ TestVariation(rawValue: $0) })
                self.type = .featureTest(.mvt)
            }
        } else {
            self.enabled = isEnabled ?? false
            self.isDevelopment = isDevelopment ?? false
            self.testVariations = defaultTestVariations
            self.type = .featureFlag
            self.testVariationAssignment = enabled ? 1.0 : 99.0
        }
        let variations = self.testVariations // Silences compiler error
        if let testBiases = testBiases,
            testBiases.reduce(Percentage.min, { (runningTotal, testBias) -> Percentage in
                return runningTotal + testBias
            }) == Percentage.max,
            testBiases.count == variations.count {
            self.testBiases = testBiases
        } else {
            self.testBiases = variations.map({ _ in
                return Percentage(rawValue: 100.0 / Double(variations.count))
            })
        }
        self.labels = try container.decodeIfPresent([String?].self, forKey: .labels)
            ?? [String?](repeating: nil, count: variations.count)
    }
    
    private static func testVariationsContains(variationNames: [String], in variations: [Test.Variation]) -> Bool {
        var variationsFound: Bool = false
        for variationName in variationNames {
            variationsFound = variations.contains(where: { testVariation in
                return testVariation.rawValue.lowercased() == variationName
            })
            if !variationsFound { break }
        }
        return variationsFound
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isDevelopment, forKey: .isDevelopment)
        try container.encode(enabled, forKey: .isEnabled)
        try container.encode(testBiases, forKey: .testBiases)
        try container.encode(testVariationAssignment, forKey: .testVariationAssignment)
        try container.encode(testVariations, forKey: .testVariations)
        try container.encode(testVariations, forKey: .labels)
    }
}

extension Feature: CustomStringConvertible {
    public var description: String {
        var result = "Feature: \(self.name)"
        result += "\nEnabled: \(self.isEnabled())"
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
