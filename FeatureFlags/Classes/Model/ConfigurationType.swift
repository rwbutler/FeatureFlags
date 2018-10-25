//
//  ConfigurationType.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation

public enum ConfigurationType: String, CaseIterable, RawRepresentable {
    case plist
    case json
}
