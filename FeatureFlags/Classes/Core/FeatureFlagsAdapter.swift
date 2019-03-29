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
}
