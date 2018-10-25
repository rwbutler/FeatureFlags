//
//  FeatureType.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public enum FeatureType {
    case deprecated
    case featureFlag
    case featureTest(FeatureTest)
}

extension FeatureType: Codable {
    
    enum CodingKeys: String, CodingKey {
        case featureFlag = "feature-flag"
        case featureTest = "feature-test"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            _ = try container.decode(String.self, forKey: .featureFlag)
            self = .featureFlag
        } catch {
            let featureTest =  try container.decode(FeatureTest.self, forKey: .featureTest)
            self = .featureTest(featureTest)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .deprecated:
            break // Don't save deprecated features - they are to be removed
        case .featureFlag:
            try container.encode(CodingKeys.featureFlag.rawValue, forKey: .featureFlag)
        case .featureTest(let featureTest):
            try container.encode(featureTest, forKey: .featureTest)
        }
    }
    
}

extension FeatureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deprecated:
            return "Deprecated"
        case .featureFlag:
            return "Feature Flag"
        case .featureTest(.ab):
            return "A/B Test"
        case .featureTest(.featureFlagAB):
             return "Feature On/Off (A/B) Test"
        case .featureTest(.mvt):
            return "MVT Test"
        }
    }
}

extension FeatureType: Equatable {
    public static func == (lhs: FeatureType, rhs: FeatureType) -> Bool {
        switch (lhs, rhs) {
        case (.featureFlag, .featureFlag),
             (.featureTest(.ab), .featureTest(.ab)),
             (.featureTest(.featureFlagAB), .featureTest(.featureFlagAB)),
             (.featureTest(.mvt), .featureTest(.mvt)):
            return true
        default:
            return false
        }
    }
}
