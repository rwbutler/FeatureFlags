//
//  Features.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct FeatureFlags {
    
    // MARK: Global state
    
    /// Defaults configuration URL to bundled configuration detecting the type of config when set
    public static var configurationURL: URL? = bundledConfigurationURL() {
        didSet { // detect configuration format by extension
            guard let lastPathComponent = configurationURL?.lastPathComponent.lowercased() else { return }
            for configurationType in ConfigurationType.allCases {
                if lastPathComponent.contains(configurationType.rawValue.lowercased()) {
                    FeatureFlags.configurationType = configurationType
                    return
                }
            }
        }
    }

    public static var configurationType: ConfigurationType = {
        for configurationType in ConfigurationType.allCases {
            if bundledConfigurationURL(configurationType) != nil {
                return configurationType
            }
        }
        return .json // default
    }()
    
    /// Removes the specified feature from the cache however the feature will remain in in-memory configuration.
    static func deleteFeatureFromCache(named name: Feature.Name) {
        // Load cached configuration, if exists
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL),
            var cachedResult = parseConfiguration(data: cachedData) {
            cachedResult = cachedResult.filter({ $0.name != name })
            cacheConfiguration(cachedResult)
        }
    }
    
    /// Deletes the feature with the specified name.
    /// Note: If the feature still exists in the JSON then it will be re-added later.
    static func deleteFeature(named name: Feature.Name) {
        deleteFeatureFromCache(named: name)
        let indexOfFeatureToBeRemoved = FeatureFlags.configuration?.firstIndex(where: { feature in
            return feature.name.rawValue == name.rawValue
        })
        if let index = indexOfFeatureToBeRemoved {
            FeatureFlags.configuration?.remove(at: index)
        }
    }

    /// Whether or not the app is running in development mode
    public static var isDevelopment: Bool = false
    
    /// Where using a remote URL, a local fallback file may be specified
    public static var localFallbackConfigurationURL: URL?

    /// Prints status of all feature flags
    public static func printFeatureFlags() {
        FeatureFlags.configuration?.forEach({ feature in
            print("\(feature.name.rawValue): Enabled -> \(feature.isEnabled())")
        })
    }
    
    public static func printExtendedFeatureFlagInformation() {
        FeatureFlags.configuration?.forEach({ feature in
            print("\(feature.description)\n")
        })
    }
    
    @discardableResult
    public static func refresh(_ completion:(() -> Void)? = nil) -> [Feature]? {
        configuration = loadConfiguration()
        completion?()
        return configuration
    }

    @discardableResult
    public static func refreshWithData(_ data: Data, completion:(() -> Void)? = nil) -> [Feature]? {
        configuration = loadConfigurationWithData(data)
        completion?()
        return configuration
    }
    
    /// Transient update - will not be persisted
    public static func updateFeatureIsEnabled(feature named: Feature.Name, isEnabled: Bool) {
        guard var updatedConfiguration = configuration, var feature = Feature.named(named) else { return }
        if let featureIndex = self.configuration?.firstIndex(where: { $0 == feature }) {
           
            if (feature.type == FeatureType.featureTest(.featureFlagAB)
                || feature.type == FeatureType.featureFlag),
                let alternateABVariant = feature.testVariations.filter({ $0 != feature.testVariation() }).first {
                updateFeatureTestVariation(feature: named, testVariation: alternateABVariant)
            } else {
                updatedConfiguration.remove(at: featureIndex)
                feature.enabled = isEnabled
                updatedConfiguration.append(feature)
                self.configuration = updatedConfiguration
            }
        }
    }

    public static func updateFeatureTestVariation(feature named: Feature.Name, testVariation: Test.Variation) {
        guard var updatedConfiguration = configuration, var feature = Feature.named(named) else { return }
        if let featureIndex = self.configuration?.firstIndex(where: { $0 == feature }) {
            updatedConfiguration.remove(at: featureIndex)
            feature.setTestVariation(testVariation)
            if testVariation == .enabled {
                feature.enabled = true
            }
            if testVariation == .disabled {
                feature.enabled = false
            }
            updatedConfiguration.append(feature)
            self.configuration = updatedConfiguration
        }
    }

}

internal extension FeatureFlags {
    
    static func bundledConfigurationURL(_ configType: ConfigurationType = FeatureFlags.configurationType) -> URL? {
        return Bundle.main.url(forResource: configurationName, withExtension: configType.rawValue)
    }
    
    private static var cachedConfigurationURL: URL? {
        return try? FileManager.default
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
            .appendingPathComponent("\(configurationName).\(configurationType.rawValue)")
    }
    
    private static func cacheConfiguration(_ result: [Feature]) {
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
    
    static func loadConfigurationWithData(_ data: Data?) -> [Feature]? {
        // Load cached configuration, if exists
        var cachedResult: ParsingServiceResult?
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL) {
            cachedResult = parseConfiguration(data: cachedData)
        }
        
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

    static func loadConfiguration() -> [Feature]? {
        var remoteData: Data?
        if let configurationURL = configurationURL {
            remoteData = try? Data(contentsOf: configurationURL)
        }
        return loadConfigurationWithData(remoteData)
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
                let firstLocalFeature = localFallback.first(where: { $0.name == remoteFeature.name })
                if let localFeature = firstLocalFeature, localFeature.isDevelopment {
                        resultFeature.isDevelopment = localFeature.isDevelopment
                }
                return resultFeature
            }
            mergedResult = mergeFeaturesNotFoundIn(mergedResult, from: localFallback)
        }

        return mergedResult
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

    private static func parseConfiguration(data: Data) -> ParsingServiceResult? {
        var parsingService: ParsingService?
        switch configurationType {
        case .plist:
            parsingService = PropertyListParsingService()
        case .json:
            parsingService = JSONParsingService()
        }
        return parsingService?.parse(data)
    }
}
