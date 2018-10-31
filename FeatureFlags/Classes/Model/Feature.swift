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
    internal var testVariationAssignment: Double
    internal var testBiases: [Percentage]
    internal let testVariations: [TestVariation]
    internal let labels: [String?]
    internal var testVariationOverride: TestVariation?
    
    public func label(testVariation: Test.Variation) -> String? {
        guard let variationLabel = zip(testVariations, labels).first(where: { $0.0 == testVariation })?.1 else {
            return nil
        }
        return variationLabel
    }
    
    public static func isEnabled(_ featureName: Feature.Name) -> Bool {
        guard let feature = named(featureName) else { return false }
        return feature.isEnabled()
    }
    
    public func isTestVariation(_ variation: TestVariation) -> Bool {
        return testVariation() == variation
    }
    
    public static func isTestVariation(feature featureName: Feature.Name, variation: Test.Variation) -> Bool {
        guard let feature = named(featureName) else { return false }
        return feature.isTestVariation(variation)
    }
    
    public func isEnabled() -> Bool {
        switch type {
        case .featureTest(.featureFlagAB):
            return testVariation().rawValue == "Enabled" ? true : false
        default:
            return enabled
        }
    }
    
    public static func named(_ featureName: Feature.Name) -> Feature? {
        guard let features = FeatureFlags.configuration else { return nil }
        return features.first(where: { $0.name == featureName })
    }
    
    func testBias(_ testVariation: Test.Variation) -> Percentage {
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
        var lowerBound = Percentage.min.rawValue
        for variation in zip(testVariations, testBiases) {
            let upperBound = lowerBound + variation.1.rawValue
            let range = lowerBound..<upperBound
            if range.contains(testVariationAssignment) {
                return variation.0
            }
            lowerBound = upperBound
        }
        fatalError("A feature must always be categorizable into a test variation.")
    }
    
    /// Returns whether or not updated successfully
    @discardableResult internal mutating func setTestVariation(_ testVariation: Test.Variation) -> Bool {
        testVariationOverride = testVariation
        return true
    }
}

extension Feature: Codable {
    enum CodingKeys: String, CodingKey {
        case name
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
        let testBiases = try container.decodeIfPresent([Percentage].self, forKey: .testBiases)
        self.testVariationAssignment = try container.decodeIfPresent(Double.self, forKey: .testVariationAssignment)
            ?? drand48() * 100
        let testVariations = try container.decodeIfPresent([String].self, forKey: .testVariations)
        let defaultTestVariations = [TestVariation(rawValue: "Enabled"), TestVariation(rawValue: "Disabled")]
        if let testVariations = testVariations {
            if testVariations.isEmpty {
                self.enabled = isEnabled ?? false
                self.testVariations = defaultTestVariations
                self.type = .featureFlag
                self.testVariationAssignment = enabled ? 1.0 : 99.0
            } else if testVariations.count == 1, let firstVariation = testVariations.first {
                self.enabled = isEnabled ?? false
                self.testVariations = [TestVariation(rawValue: firstVariation), TestVariation(rawValue: "!\(firstVariation)")]
                self.type = .featureFlag
            } else if testVariations.count == 2 {
                self.enabled = isEnabled ?? true
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
                self.testVariations = testVariations.map({ TestVariation(rawValue: $0) })
                self.type = .featureTest(.mvt)
            }
        } else {
            self.enabled = isEnabled ?? false
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
        try container.encode(enabled, forKey: .isEnabled)
        try container.encode(testBiases, forKey: .testBiases)
        try container.encode(testVariationAssignment, forKey: .testVariationAssignment)
        try container.encode(testVariations, forKey: .testVariations)
        try container.encode(testVariations, forKey: .labels)
    }
}

extension Feature: Equatable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool {
        return lhs.name == rhs.name
    }
}
