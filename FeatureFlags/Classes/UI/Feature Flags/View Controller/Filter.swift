//
//  Filter.swift
//  FeatureFlags
//
//  Created by Ross Butler on 23/12/2019.
//

import Foundation

typealias FeatureSection = String?

enum Filter {
    case section(_ section: FeatureSection)
    case type(_ type: FeatureType)
    
    var name: String {
        switch self {
        case .section(let sectionName):
            return sectionName ?? "Uncategorized"
        case .type(let featureType):
            return featureType.description
        }
    }
}
