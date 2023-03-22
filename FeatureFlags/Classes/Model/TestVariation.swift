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
    
    private static let disabledRawValues = ["disabled", "off"]
    private static let enabledRawValues = ["enabled", "on"]
    private let name: RawValue
    public typealias RawValue = String
    
    public init(rawValue: RawValue) {
        name = Self.name(from: rawValue)
    }
    
    public var rawValue: RawValue {
        return name
    }
    
    static func name(from rawValue: RawValue) -> String {
        if disabledRawValues.contains(rawValue) {
            return Self.disabled.rawValue
        } else if enabledRawValues.contains(rawValue) {
            return Self.enabled.rawValue
        } else {
            return rawValue
        }
    }
}

extension TestVariation: Equatable {
    public static func == (lhs: TestVariation, rhs: TestVariation) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension TestVariation: Comparable {
    public static func < (lhs: TestVariation, rhs: TestVariation) -> Bool {
        lhs.rawValue.lowercased() < rhs.rawValue.lowercased()
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
