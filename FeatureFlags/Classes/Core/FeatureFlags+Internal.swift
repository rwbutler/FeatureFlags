//
//  FeatureFlags+Internal.swift
//  FeatureFlags
//
//  Created by Ross Butler on 3/7/19.
//

import Foundation

extension FeatureFlags {
    
    static func bundledConfigurationURL(_ configType: ConfigurationType = FeatureFlags.configurationType) -> URL? {
        return Bundle.main.url(forResource: configurationName, withExtension: configType.rawValue)
    }
    
    static var cachedConfigurationURL: URL? {
        return try? FileManager.default
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
            .appendingPathComponent("\(configurationName).\(configurationType.rawValue)")
    }
    
    static func cacheConfiguration(_ result: [Feature]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(result),
            let cachedConfigurationURL = cachedConfigurationURL else { return }
        try? data.write(to: cachedConfigurationURL)
    }
    
    static func cacheExists() -> Bool {
        guard let cachedConfigURL = cachedConfigurationURL else { return false }
        return FileManager.default.fileExists(atPath: cachedConfigURL.path)
    }
    
    static func clearCache() {
        guard let cachedConfigURL = cachedConfigurationURL else { return }
        try? FileManager.default.removeItem(at: cachedConfigURL)
    }
    
    static var configuration: [Feature]? = loadConfiguration()
    
    static let configurationName: String = "Features"
    
    static func loadCachedConfiguration() -> [Feature]? {
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL) {
            return parseConfiguration(data: cachedData)
        }
        return nil
    }
    
    static func loadConfiguration() -> [Feature]? {
        var remoteData: Data?
        if let configurationURL = configurationURL {
            remoteData = try? Data(contentsOf: configurationURL)
        }
        return loadConfigurationWithData(remoteData)
    }
    
    static func loadConfigurationWithData(_ data: Data?) -> [Feature]? {
        // Load cached configuration, if exists
        let cachedResult = loadCachedConfiguration()
        
        // Load remote data
        if let remoteData = data,
            let remoteResult = parseConfiguration(data: remoteData) {
            // If fallback URL is set - fallback to local config file
            let localFallbackResult: ParsingServiceResult?
            if let localFallbackURL = localFallbackConfigurationURL,
                let localFallbackData = try? Data(contentsOf: localFallbackURL) {
                localFallbackResult = parseConfiguration(data: localFallbackData)
            } else {
                localFallbackResult = nil
            }
            
            // Update remote feature flag data with existing test variation assignments
            let updatedRemoteResult = updateWithTestVariationAssignments(remoteResult,
                                                                         storedResult: cachedResult,
                                                                         localFallbackResult: localFallbackResult)
            cacheConfiguration(updatedRemoteResult) // cache merged result
            return updatedRemoteResult
        } else if let storedResult = cachedResult {
            // Couldn't access remote configuration - merge fallback into cached result
            let localFallbackResult: ParsingServiceResult?
            if let localFallbackURL = localFallbackConfigurationURL,
                let localFallbackData = try? Data(contentsOf: localFallbackURL) {
                localFallbackResult = parseConfiguration(data: localFallbackData)
            } else if let bundledConfigurationURL = bundledConfigurationURL(),
                let bundledData = try? Data(contentsOf: bundledConfigurationURL) {
                localFallbackResult = parseConfiguration(data: bundledData)
            } else {
                localFallbackResult = nil
            }
            let updatedResult = updateWithTestVariationAssignments(storedResult,
                                                                   storedResult: storedResult,
                                                                   localFallbackResult: localFallbackResult)
            return updatedResult
        } else if let localFallbackURL = localFallbackConfigurationURL,
            let localFallbackData = try? Data(contentsOf: localFallbackURL) {
            let localFallbackResult = parseConfiguration(data: localFallbackData)
            if !cacheExists(), let result = localFallbackResult {
                cacheConfiguration(result)
            }
            return localFallbackResult
        } else if let bundledConfigurationURL = bundledConfigurationURL(),
            let bundledData = try? Data(contentsOf: bundledConfigurationURL) {
            let bundledResult = parseConfiguration(data: bundledData)
            if !cacheExists(), let result = bundledResult {
                cacheConfiguration(result)
            }
            return bundledResult
        }
        return nil
    }
    
    private static func mergeFeaturesNotFoundIn(_ lhs: [Feature], from rhs: [Feature]) -> [Feature] {
        var result = lhs
        let disjointFeatures = rhs.filter({ rhsFeature in
            return !lhs.contains(where: { lhsFeature in
                rhsFeature.name == lhsFeature.name
            })
        })
        result.append(contentsOf: disjointFeatures)
        return result
    }
    
    static func parseConfiguration(data: Data) -> ParsingServiceResult? {
        var parsingService: ParsingService?
        switch configurationType {
        case .plist:
            parsingService = PropertyListParsingService()
        case .json:
            parsingService = JSONParsingService()
        }
        return parsingService?.parse(data)
    }
    
    private static func updateWithTestVariationAssignments(_ remoteResult: [Feature],
                                                           storedResult: [Feature]?,
                                                           localFallbackResult: [Feature]? = nil)
        -> [Feature] {
            var mergedResult: [Feature] = []
            for remoteFeature in remoteResult {
                var updatedRemoteFeature = remoteFeature
                if let storedFeature = storedResult?.first(where: { $0.name == remoteFeature.name }) {
                    updatedRemoteFeature.testVariationAssignment = storedFeature.testVariationAssignment
                    updatedRemoteFeature.unlocked = storedFeature.unlocked
                }
                mergedResult.append(updatedRemoteFeature)
            }
            // Add in any features not defined remotely
            if let stored = storedResult {
                mergedResult = mergeFeaturesNotFoundIn(mergedResult, from: stored)
            }
            
            if let localFallback = localFallbackResult {
                // Update development status of remote features from local
                mergedResult = mergedResult.map { remoteFeature in
                    var resultFeature: Feature = remoteFeature
                    if let localFeature = localFallback.first(where: { $0.name == remoteFeature.name }) {
                        // Should remain true if has ever previously been set to true
                        resultFeature.isDevelopment = resultFeature.isDevelopment || localFeature.isDevelopment
                    }
                    return resultFeature
                }
                mergedResult = mergeFeaturesNotFoundIn(mergedResult, from: localFallback)
            }
            
            return mergedResult
    }
}
