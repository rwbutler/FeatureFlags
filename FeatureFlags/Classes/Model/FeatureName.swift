//
//  FeatureName.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct FeatureName: RawRepresentable {
    private let name: RawValue
    public typealias RawValue = String
    
    public init(rawValue: RawValue) {
        self.name = rawValue
    }
    
    public var rawValue: RawValue {
        return self.name
    }
}

extension FeatureName: Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }
}

extension FeatureName: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
