//
//  Features.swift
//  FeatureFlags_Example
//
//  Created by Ross Butler on 10/22/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import FeatureFlags

extension Feature.Name {
    static let exampleFeatureFlag = Feature.Name(rawValue: "Example Feature Flag")
    static let exampleUnlockFlag = Feature.Name(rawValue: "Example Unlock Flag")
    static let exampleABTest = Feature.Name(rawValue: "Example A/B Test")
    static let exampleFeatureOnOffTest = Feature.Name(rawValue: "Example Feature On/Off A/B Test")
    static let exampleMVTTest = Feature.Name(rawValue: "Example MVT Test")
}

extension Test.Variation {
    static let groupA = Test.Variation(rawValue: "Group A")
    static let groupB = Test.Variation(rawValue: "Group B")
    static let groupC = Test.Variation(rawValue: "Group C")
}
