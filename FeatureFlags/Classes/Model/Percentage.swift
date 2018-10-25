//
//  Percentage.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct Percentage: RawRepresentable {
    
    // MARK: Global state
    static let min: Percentage = Percentage(rawValue: 0.0)
    static let max: Percentage = Percentage(rawValue: 100.0)
    
    // MARK: Type definitions
    public typealias RawValue = Double
    
    // MARK: State
    private let value: RawValue
    
    public init(rawValue: RawValue) {
        switch rawValue {
        case 0.0...100.0:
            self.value = rawValue
        case ..<0.0:
            self.value = 0.0
        default:
            self.value = 100.0
        }
    }
    
    public var rawValue: RawValue {
        return value
    }
    
    static func +(left: Percentage, right: Percentage) -> Percentage {
        return Percentage(rawValue: left.rawValue + right.rawValue)
    }
}

extension Percentage: Codable {
    enum CodingKeys: String, CodingKey {
        case value
    }
}

extension Percentage: CustomStringConvertible {
    public var description: String {
        return "\(String(describing: rawValue))%"
    }
}
