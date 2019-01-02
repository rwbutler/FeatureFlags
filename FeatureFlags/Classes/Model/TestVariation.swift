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
    public static let a = Test.Variation(rawValue: "A")
    public static let b = Test.Variation(rawValue: "B")
    public static let c = Test.Variation(rawValue: "C")
    public static let d = Test.Variation(rawValue: "D")
    public static let e = Test.Variation(rawValue: "E")
    public static let f = Test.Variation(rawValue: "F")
    
    // Note: A logic error has occurred and a Test.Variation could not be assigned.
    public static let unassigned = Test.Variation(rawValue: "Unassigned")
    
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
