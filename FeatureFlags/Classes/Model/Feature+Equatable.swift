//
//  Feature+Equatable.swift
//  FeatureFlags
//
//  Created by Ross Butler on 11/21/18.
//

import Foundation

extension Feature: Equatable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool {
        return lhs.name == rhs.name
    }
}

extension FeatureName: Equatable {
    public static func == (lhs: FeatureName, rhs: FeatureName) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
