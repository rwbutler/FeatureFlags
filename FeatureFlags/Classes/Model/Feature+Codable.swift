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
    static let defaultTestVariations: [TestVariation] = [.enabled, .disabled]
    
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
        self.unlocked = unlocked
        let parsedTestVariations: [TestVariation]
        if let testVariations = testVariations {
            switch testVariations.count {
            case 0:
                self.isDevelopment = isDevelopment ?? false
                self.enabled = isEnabled ?? false
                self.type = type ?? .featureFlag
                self.testVariationAssignment = enabled ? 1.0 : 99.0
                parsedTestVariations = Self.defaultTestVariations
            case 1:
                self.enabled = isEnabled ?? false
                self.isDevelopment = isDevelopment ?? false
                self.type = type ?? .featureFlag
                if let firstVariation = testVariations.first {
                    parsedTestVariations = [
                        TestVariation(rawValue: firstVariation),
                        TestVariation(rawValue: "!\(firstVariation)")
                    ]
                } else {
                    parsedTestVariations = Self.defaultTestVariations
                }
            case 2:
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                parsedTestVariations = testVariations.map {
                    TestVariation(rawValue: $0)
                }
                self.type = parsedTestVariations.sorted() == Self.defaultTestVariations.sorted()
                ? .featureTest(.featureFlagAB)
                : .featureTest(.ab)
            default:
                self.enabled = isEnabled ?? true
                self.isDevelopment = isDevelopment ?? false
                parsedTestVariations = testVariations.map {
                    TestVariation(rawValue: $0)
                }
                self.type = type ?? .featureTest(.mvt)
            }
        } else {
            self.enabled = isEnabled ?? false
            self.isDevelopment = isDevelopment ?? false
            self.type = type ?? .featureFlag
            self.testVariationAssignment = enabled ? 1.0 : 99.0
            parsedTestVariations = Self.defaultTestVariations
        }
        self.testVariations = parsedTestVariations
        if let testBiases = testBiases,
           testBiases.reduce(Percentage.min, { (runningTotal, testBias) -> Percentage in
               return runningTotal + testBias
           }) == Percentage.max,
           testBiases.count == parsedTestVariations.count {
            self.testBiases = testBiases
        } else {
            self.testBiases = parsedTestVariations.map({ _ in
                return Percentage(rawValue: 100.0 / Double(parsedTestVariations.count))
            })
        }
        self.labels = try container.decodeIfPresent([String?].self, forKey: .labels)
        ?? [String?](repeating: nil, count: parsedTestVariations.count)
        self.testVariationOverride = nil
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
