//
//  FeatureTest.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public enum FeatureTest: String, Codable {
    case ab
    case featureFlagAB
    case mvt
}
