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
    
    /// Presents FeatureFlagsViewController modally
    public static func presentFeatureFlags(delegate: FeatureFlagsViewControllerDelegate? = nil) {
        guard let presenter = UIApplication.shared.keyWindow?.rootViewController else { return }
        let featureFlagsViewController = FeatureFlagsViewController(style: .grouped)
        featureFlagsViewController.delegate = delegate
        featureFlagsViewController.modalPresentationStyle = .overCurrentContext
        let navigationController = UINavigationController(rootViewController: featureFlagsViewController)
        presenter.present(navigationController, animated: true, completion: nil)
    }
    
    /// Allows FeatureFlagsViewController to be pushed onto a navigation stack
    public static func pushFeatureFlags(delegate: FeatureFlagsViewControllerDelegate? = nil, navigationController: UINavigationController, animated: Bool = false) {
        let featureFlagsViewController = FeatureFlagsViewController(style: .grouped)
        let navigationSettings = FeatureFlagsViewController
            .NavigationSettings(animated: animated, autoClose: true, isNavigationBarHidden: navigationController.isNavigationBarHidden)
        featureFlagsViewController.delegate = delegate
        featureFlagsViewController.navigationSettings = navigationSettings
        navigationController.isNavigationBarHidden = false
        navigationController.pushViewController(featureFlagsViewController, animated: animated)
    }
    
    public static func pushFeatureFlags(delegate: FeatureFlagsViewControllerDelegate? = nil,  navigationController: UINavigationController, navigationSettings: FeatureFlagsViewControllerNavigationSettings) {
        let featureFlagsViewController = FeatureFlagsViewController(style: .grouped)
        featureFlagsViewController.delegate = delegate
        featureFlagsViewController.navigationSettings = navigationSettings
        navigationController.isNavigationBarHidden = false
        navigationController.pushViewController(featureFlagsViewController, animated: navigationSettings.animated)
    }
    
    public static func refresh(_ completion:(()-> Void)? = nil) {
        configuration = loadConfiguration(completion)
    }
    
    public static func refreshWithData(_ data: Data, completion:(()-> Void)? = nil) {
        configuration = loadConfigurationWithData(data, completion: completion)
    }
    
    /// Transient update - will not be persisted
    public static func updateFeatureIsEnabled(feature named: Feature.Name, isEnabled: Bool) {
        guard var updatedConfiguration = configuration, var feature = Feature.named(named) else { return }
        if let featureIndex = self.configuration?.firstIndex(where: { $0 == feature }) {
            updatedConfiguration.remove(at: featureIndex)
            feature.enabled = isEnabled
            
            if (feature.type == FeatureType.featureTest(.featureFlagAB)
                || feature.type == FeatureType.featureFlag),
                let alternateABVariant = feature.testVariations.filter({ $0 != feature.testVariation() }).first {
                feature.setTestVariation(alternateABVariant)
            }
            updatedConfiguration.append(feature)
            self.configuration = updatedConfiguration
        }
    }
    
    public static func updateFeatureTestVariation(feature named: Feature.Name, testVariation: Test.Variation) {
        guard var updatedConfiguration = configuration, var feature = Feature.named(named) else { return }
        if let featureIndex = self.configuration?.firstIndex(where: { $0 == feature }) {
            updatedConfiguration.remove(at: featureIndex)
            feature.setTestVariation(testVariation)
            updatedConfiguration.append(feature)
            self.configuration = updatedConfiguration
        }
    }

}

internal extension FeatureFlags {
    
    private static var cachedConfigurationURL: URL? {
        return try? FileManager.default
            .url(for: .cachesDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: true)
            .appendingPathComponent("\(configurationName).\(configurationType.rawValue)")
    }
    
    static var configuration: ParsingServiceResult? = loadConfiguration()
    
    static let configurationName: String = "Features"
    
    static func bundledConfigurationURL(_ configType: ConfigurationType = FeatureFlags.configurationType) -> URL? {
        return Bundle.main.url(forResource: configurationName, withExtension: configType.rawValue)
    }
    
    static func loadConfigurationWithData(_ data: Data?, completion:(()-> Void)? = nil) -> ParsingServiceResult? {
        // Load cached configuration, if exists
        var cachedResult: ParsingServiceResult?
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL) {
            cachedResult = parseConfiguration(data: cachedData)
        }
        
        // Load remote data
        if let remoteData = data,
            let remoteResult = parseConfiguration(data: remoteData) {
            if let storedResult = cachedResult {
                
                // Update remote feature flag data with existing test variation assignments
                let updatedRemoteResult = updateWithTestVariationAssignments(remoteResult, storedResult: storedResult)
                cacheConfiguration(updatedRemoteResult) // cache merged result
                completion?()
                return updatedRemoteResult
            } else {
                cacheConfiguration(remoteResult)
                completion?()
                return remoteResult
            }
        } else if let storedResult = cachedResult {
            completion?()
            return storedResult
        } else if let bundledConfigurationURL = bundledConfigurationURL(),
            let bundledData = try? Data(contentsOf: bundledConfigurationURL) {
            let bundledResult = parseConfiguration(data: bundledData)
            completion?()
            return bundledResult
        }
        completion?()
        return nil
    }
    
    static func loadConfiguration(_ completion:(()-> Void)? = nil) -> ParsingServiceResult? {
        
        // Load cached configuration, if exists
        var cachedResult: ParsingServiceResult?
        if let cachedConfigurationURL = cachedConfigurationURL,
            let cachedData = try? Data(contentsOf: cachedConfigurationURL) {
                cachedResult = parseConfiguration(data: cachedData)
        }
        
        // Load remote data
        if let configurationURL = configurationURL,
            let data = try? Data(contentsOf: configurationURL),
            let remoteResult = parseConfiguration(data: data) {
            if let storedResult = cachedResult {
                
                // Update remote feature flag data with existing test variation assignments
                let updatedRemoteResult = updateWithTestVariationAssignments(remoteResult, storedResult: storedResult)
                cacheConfiguration(updatedRemoteResult) // cache merged result
                completion?()
                return updatedRemoteResult
            } else {
                cacheConfiguration(remoteResult)
                completion?()
                return remoteResult
            }
        } else if let storedResult = cachedResult {
            completion?()
            return storedResult
        } else if let bundledConfigurationURL = bundledConfigurationURL(),
            let bundledData = try? Data(contentsOf: bundledConfigurationURL) {
            let bundledResult = parseConfiguration(data: bundledData)
            completion?()
            return bundledResult
        }
        completion?()
        return nil
    }
    
    private static func cacheConfiguration(_ result: ParsingServiceResult) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(result),
            let cachedConfigurationURL = cachedConfigurationURL else { return }
        do {
        try data.write(to: cachedConfigurationURL)
        } catch let e {
            print(e)
        }
    }
    
    private static func updateWithTestVariationAssignments(_ remoteResult: ParsingServiceResult, storedResult: ParsingServiceResult) -> ParsingServiceResult {
        var mergedResult: ParsingServiceResult = []
        for remoteFeature in remoteResult {
            var updatedRemoteFeature = remoteFeature
            if let storedFeature = storedResult.first(where: { $0.name == remoteFeature.name }) {
                updatedRemoteFeature.testVariationAssignment = storedFeature.testVariationAssignment
            }
            mergedResult.append(updatedRemoteFeature)
        }
        // Add in any features not defined remotely
        let localOnlyFeatures = storedResult.filter({ storedFeature in
            return !remoteResult.contains(where: { remoteFeature in
                storedFeature.name == remoteFeature.name
            })
        })
        mergedResult.append(contentsOf: localOnlyFeatures)
        return mergedResult
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
