//
//  Test.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/22/18.
//

import Foundation

public class Test {
    public typealias Variation = TestVariation
    let feature: Feature
    
    public required init?(rawValue: Feature.Name) {
        // Confirm feature has been defined
        guard let features = FeatureFlags.configuration,
            let feature = features.first(where: { $0.name == rawValue }) else {
                return nil
        }
        switch feature.type {
        case .deprecated, .featureFlag:
            return nil
        case .featureTest:
            self.feature = feature
        }
    }
    
    public func variation() -> Test.Variation {
        return feature.testVariation()
    }
}

extension Test: RawRepresentable {
    public typealias RawValue = Feature.Name
    
    public var rawValue: Feature.Name {
        return feature.name
    }
}

public class ABTest: Test {
    
    public required init?(rawValue: Feature.Name) {
        super.init(rawValue: rawValue)
        switch feature.type {
        case .featureTest(.ab):
            break
        default:
            return nil
        }
    }
    
    public func isGroupA() -> Bool {
        guard feature.testVariations.count == 2 else {
            return false
        }
        let groupAVariation = feature.testVariations[0]
        return feature.testVariation() == groupAVariation
    }
    
    public func isGroupB() -> Bool {
        guard feature.testVariations.count == 2 else {
            return false
        }
        let groupBVariation = feature.testVariations[1]
        return feature.testVariation() == groupBVariation
    }
}
