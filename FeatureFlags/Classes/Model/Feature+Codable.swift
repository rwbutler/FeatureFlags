//
//  Feature+Codable.swift
//  FeatureFlags
//
//  Created by Ross Butler on 3/7/19.
//

import Foundation

extension Feature: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case section
        case isDevelopment = "development"
        case isEnabled = "enabled"
        case isUnlocked = "unlocked"
        case type
        case testBiases = "test-biases"
        case testVariationAssignment = "test-variation-assignment"
        case testVariations = "test-variations"
        case labels = "labels"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(FeatureName.self, forKey: .name)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .description)
        self.section = try container.decodeIfPresent(String.self, forKey: .section)
        let isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled)
        let isDevelopment = try container.decodeIfPresent(Bool.self, forKey: .isDevelopment)
        var type = try container.decodeIfPresent(FeatureType.self, forKey: .type)
        let unlocked = try container.decodeIfPresent(Bool.self, forKey: .isUnlocked)
        if unlocked != .none {
            type = .unlockFlag
        } else if type == .some(.unlockFlag) {
            type = nil
        }
        let testBiases = try container.decodeIfPresent([Percentage].self, forKey: .testBiases)
        self.testVariationAssignment = try container.decodeIfPresent(Double.self, forKey: .testVariationAssignment)
            ?? Double.random(in: 0..<100) // [0.0, 100.0)
        let testVariations = try container.decodeIfPresent([String].self, forKey: .testVariations)
        let defaultTestVariations = [TestVariation(rawValue: "Enabled"), TestVariation(rawValue: "Disabled")]
        self.unlocked = unlocked
        if let testVariations = testVariations {
            if testVariations.isEmpty {
                self.isDevelopment = isDevelopment ?? false
                self.enabled = isEnabled ?? false
                self.testVariations = defaultTestVariations
                self.type = type ?? .featureFlag
                self.testVariationAssignment = enabled ? 1.0 : 99.0
            } else if testVariations.count == 1, let firstVariation = testVariations.first {
                self.enabled = isEnabled ?? false
                self.isDevelopment = isDevelopment ?? false
                self.testVariations = [TestVariation(rawValue: firstVariation),
                                       TestVariation(rawValue: "!\(firstVariation)")]
                self.type = type ?? .featureFlag
            } else if testVariations.count == 2 {
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                let testVariations = testVariations.map({ TestVariation(rawValue: $0) })
                if Feature.testVariationsContains(variationNames: ["enabled", "disabled"], in: testVariations)
                    || Feature.testVariationsContains(variationNames: ["on", "off"], in: testVariations) {
                    self.type = type ?? .featureTest(.featureFlagAB)
                    if ["disabled", "off"].contains(testVariations.first?.rawValue.lowercased()) {
                        self.testVariations = defaultTestVariations.reversed()
                    } else {
                        self.testVariations = defaultTestVariations
                    }
                } else {
                    self.type = type ?? .featureTest(.ab)
                    self.testVariations = testVariations
                }
            } else {
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                self.testVariations = testVariations.map({ TestVariation(rawValue: $0) })
                self.type = type ?? .featureTest(.mvt)
            }
        } else {
            self.enabled = isEnabled ?? false
            self.isDevelopment = isDevelopment ?? false
            self.testVariations = defaultTestVariations
            self.type = type ?? .featureFlag
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
        self.testVariationOverride = nil
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
        try container.encodeIfPresent(detailText, forKey: .description)
        try container.encodeIfPresent(section, forKey: .section)
        try container.encode(isDevelopment, forKey: .isDevelopment)
        try container.encode(enabled, forKey: .isEnabled)
        try container.encode(type, forKey: .type)
        try container.encode(testBiases, forKey: .testBiases)
        try container.encode(testVariationAssignment, forKey: .testVariationAssignment)
        try container.encode(testVariations, forKey: .testVariations)
        try container.encode(labels, forKey: .labels)
        try container.encode(unlocked, forKey: .isUnlocked)
    }
}
