//
//  FeatureFlagsViewModel.swift
//  FeatureFlags
//
//  Created by Ross Butler on 23/12/2019.
//

import Foundation

class FeatureFlagsViewModel {
    
    /// One section for the filter button and another for cells.
    private let defaultSectionCount = 1
    
    private var appliedFilter: Filter?
    
    func applyFilter(_ filter: Filter) {
        self.appliedFilter = filter
    }
    
    func clearFilters() {
        appliedFilter = nil
    }
    
    func deleteFeature(at indexPath: IndexPath) {
        if let feature = self.feature(for: indexPath) {
            FeatureFlags.deleteFeature(named: feature.name)
        }
    }
    
    func feature(for indexPath: IndexPath) -> Feature? {
        let sectionIdx = indexPath.section
        let rowIdx = indexPath.row
        if let filter = appliedFilter {
            let features: [Feature]?
            switch filter {
            case .section(let sectionName):
                features = FeatureFlags.filter(sectionName)
            case .type(let featureType):
                features = FeatureFlags.filter(featureType)
            }
            let sortedFeatures = self.sortedFeatures(features)
            let feature = sortedFeatures[rowIdx]
            return feature
        }
        let sections = FeatureFlags.sections()
        guard !sections.isEmpty else {
            let features = FeatureFlags.configuration
            let sortedFeatures = self.sortedFeatures(features)
            return sortedFeatures[rowIdx]
        }
        let section = sections[sectionIdx]
        let features = FeatureFlags.filter(section)
        let sortedFeatures = self.sortedFeatures(features)
        return sortedFeatures[rowIdx]
    }
    
    func filtersBySection() -> [Filter] {
        return FeatureFlags.sections().map { Filter.section($0) }
    }
    
    func filtersByType() -> [Filter] {
        return FeatureType.all.map { Filter.type($0) }
    }
    
    func filterIsApplied() -> Bool {
        return appliedFilter != nil
    }
    
    func numberOfRows(in section: Int) -> Int {
        if let filter = appliedFilter {
            switch filter {
            case .section(let sectionName):
                guard let features = FeatureFlags.filter(sectionName) else {
                    return 0
                }
                return features.count
            case .type(let featureType):
                guard let features = FeatureFlags.filter(featureType) else {
                    return 0
                }
                return features.count
            }
        }
        let sections = FeatureFlags.sections()
        guard !sections.isEmpty else {
            let features = FeatureFlags.configuration
            return features?.count ?? 0
        }
        let section = sections[section]
        let features = FeatureFlags.filter(section)
        return features?.count ?? 0
    }
    
    func numberOfSections() -> Int {
        guard appliedFilter == nil else {
            return defaultSectionCount
        }
        let sections = FeatureFlags.sections()
        return (!sections.isEmpty) ? sections.count : defaultSectionCount
    }
    
    func sectionTitle(for sectionIdx: Int) -> String? {
        if let filter = appliedFilter {
            return filter.name
        }
        let sections = FeatureFlags.sections()
        guard !sections.isEmpty else {
            return ""
        }
        let section = sections[sectionIdx]
        return section ?? "Uncategorized"
    }
    
    func sortedFeatures(_ features: [Feature]?) -> [Feature] {
        guard var mutableFeatures = features else {
            return []
        }
        mutableFeatures.sort(by: { (lhs, rhs) -> Bool in
            return lhs.name.rawValue < rhs.name.rawValue
        })
        return mutableFeatures
    }
    
}
