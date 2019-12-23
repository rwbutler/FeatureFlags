//
//  Features.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/18/18.
//

import Foundation

public struct FeatureFlags {
    
    // MARK: Global state
    
    public static func addFeature(_ feature: Feature) {
        if let existingFeature = configuration?.first(where: { $0.name == feature.name }) {
            print("Feature named \(existingFeature.name.description) already exists.")
            return
        }
        if var configuration = configuration {
            configuration.append(feature)
            cacheConfiguration(configuration)
        }
    }
    
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

    /// Returns only feature flags of the specified type. Used by `FeatureFlagsViewController` to provide
    /// filtering.
    public static func filter(_ section: String) -> [Feature]? {
        return configuration?.filter {
            guard let featureSection = $0.section else {
                return false
            }
            return section == featureSection
        }
    }
    
    /// Returns only feature flags of the specified type. Used by `FeatureFlagsViewController` to provide
    /// filtering.
    public static func filter(_ type: FeatureType) -> [Feature]? {
        return configuration?.filter { $0.type == type }
    }
    
    /// Whether or not the app is running in development mode
    public static var isDevelopment: Bool = false
    
    static func isNoLongerUnderDevelopment(named name: Feature.Name) {
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL),
            let cachedResult = parseConfiguration(data: cachedData) {
            let featureToRemove = cachedResult.first(where: { $0.name == name })
            let shouldRemoveFeature = featureToRemove?.isDevelopment ?? false
            if shouldRemoveFeature {
                let updatedResult = cachedResult.filter({ $0.name != name })
                cacheConfiguration(updatedResult)
            }
        }
    }
    
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
    
    /// Returns all sections titles for those features which have a section specified.
    public static func sections() -> [String] {
        let allSections = configuration?.compactMap { $0.section }
        let distinctSections = allSections?.mapDistinct { $0 } ?? []
        return distinctSections.sorted()
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
