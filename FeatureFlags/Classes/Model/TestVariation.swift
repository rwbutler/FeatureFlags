//
//  TestVariation.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct TestVariation: RawRepresentable {
    
    // MARK: Global state
    public static let enabled = Test.Variation(rawValue: "Enabled")
    public static let disabled = Test.Variation(rawValue: "Disabled")
    
    private let name: RawValue
    public typealias RawValue = String
    
    public init(rawValue: RawValue) {
        self.name = rawValue
    }
    
    public var rawValue: RawValue {
        return self.name
    }
}

extension TestVariation: Equatable {
    public static func == (lhs: TestVariation, rhs: TestVariation) -> Bool {
        return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension TestVariation: Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }
}

extension TestVariation: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
