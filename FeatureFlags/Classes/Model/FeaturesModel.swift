//
//  FeaturesModel.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct FeaturesModel: Codable {
    let features: [FeatureModel]
    
    enum CodingKeys: String, CodingKey {
        case features
    }
}

public struct FeatureModel: Codable {
    let name: String
    let isEnabled: Bool
    let testBiases: [Double]?
    let testVariations: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case isEnabled = "enabled"
        case testBiases = "test-biases"
        case testVariations = "test-variations"
    }
}
