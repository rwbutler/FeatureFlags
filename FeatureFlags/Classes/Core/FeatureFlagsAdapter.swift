//
//  FeatureFlagsAdapter.swift
//  FeatureFlags
//
//  Created by Ross Butler on 11/8/18.
//

import Foundation

@objc public class FeatureFlagsAdapter: NSObject {
    @objc public static func isEnabled(_ feature: NSString) -> Bool {
        let featureName = Feature.Name(rawValue: feature as String)
        return Feature.isEnabled(featureName)
    }
    
    @objc public static func label(_ testName: NSString) -> NSString? {
        let featureName = Feature.Name(rawValue: testName as String)
        guard let feature = Feature(named: featureName) else {
            return nil
        }
        let variation = feature.testVariation()
        return feature.label(variation) as NSString?
    }
    
    @objc public static func testVariation(_ testName: NSString) -> NSString? {
        let featureName = Feature.Name(rawValue: testName as String)
        guard let feature = Feature(named: featureName) else {
            return nil
        }
        // The variation is group the user is in for this particular test.
        let variation = feature.testVariation()
        return variation.rawValue as NSString
    }
    
    @objc public static func userIsInTest(_ testName: NSString, variation: NSString) -> Bool {
        guard let userTestVariation = testVariation(testName) else {
            return false
        }
        return variation.isEqual(to: userTestVariation as String)
    }
}
