# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2018-12-05
### Added
- Added function `printFeatureFlags()` for printing flag status.
- Added function `printExtendedFeatureFlagInformation()` for printing more detailed flag information.
- Boundary tests to ensure user assigned to the correct A/B testing group.

## [1.2.1] - 2018-11-29
### Changed
- Fixed an issue where feature flag value could not be toggled through the UI.

## [1.2.0] - 2018-11-27
### Added
- Added support for Swift Package Manager.
### Changed
- Refactored to satisfy linting rules.

## [1.1.2] - 2018-11-26
### Changed
- Added documentation on development flags.

## [1.1.1] - 2018-11-19
### Changed
- Fixed an issue where if remote configuration could not be parsed, then fell back to cached configuration without making use of local fallback data in other loadConfiguration(:) method and refactored to eliminate code duplication.

### Changed
## [1.1.0] - 2018-11-17
### Added
- Support for development flags such that a feature flag can be marked such that the feature is never released unfinished even if remotely enabled later. To mark a feature as in development set the `development` property to `true` in the local fallback configuration.
### Changed
- Fixed an issue where if remote configuration could not be parsed, then fell back to cached configuration without making use of local fallback data.
- Fixed an issue where an expected error was printed whilst making a fallback parsing attempt.

## [1.0.4] - 2018-11-08
### Changed
- Allow for greater granularity in terms of navigation settings when pushing / presenting FeatureFlagsViewController.

## [1.0.3] - 2018-11-08
### Added
- Support for checking whether a feature is enabled in Objective-C using FEATURE_IS_ENABLED macro.

## [1.0.2] - 2018-11-06
### Added
- Made it possible to configure whether feature flag data is refreshed prior to displaying FeatureFlagsViewController.

## [1.0.1] - 2018-11-02
### Changed
- Corrections and additional information added to documentation.

## [1.0.0] - 2018-11-02
### Added
- Provided usage documentation.
### Changed
- Method name (for retrieval of analytics labels) updated from:

```
public func label(testVariation: Test.Variation) -> String?
```

To:

```
public func label(_ testVariation: Test.Variation) -> String?
```

## [0.1.2] - 2018-11-02
### Changed
- Fixed an issue whereby labels and test variations were returned even after a feature was disabled. Once a feature is globally disabled, a user should no longer belong to a test variation (for analytics purposes).

## [0.1.1] - 2018-11-01
### Changed
- Ensures that FeatureFlagsViewController refreshes feature flags on load so that information is always up-to-date.

## [0.1.0] - 2018-11-01
### Changed
- Fixed a bug which resulted in a crash on swiping to delete a feature which existed in the remote data source and not solely in the cache.

## [0.0.9] - 2018-11-01
### Added
- A local configuration may now be specified as a fallback allowing features to be added locally which are not present in the remote configuration.
- Swipe to delete features from cache using FeatureFlagsViewController.

## [0.0.8] - 2018-11-01
### Changed
- Made it possible to refresh configuration by passing data to be parsed directly into the refreshData(:completion:) method.

## [0.0.7] - 2018-10-31
### Changed
- Made possible to position FeatureFlagsViewController close button on the left or right-hand side via navigation settings object.

## [0.0.6] - 2018-10-31
### Changed
- Fixed an issue whereby it was not possible to toggle A/B groups where test biases set to 0% and 100%.

## [0.0.5] - 2018-10-31
### Changed
- Ensured that UITableViewCell labels wrap correctly.

## [0.0.4] - 2018-10-31
### Changed
- Ensured that a delegate can be passed into FeatureFlagsViewController.

## [0.0.3] - 2018-10-30
### Added
- FeatureFlagsViewControllerDelegate allows caller to be informed when view controller work is complete.
### Changed
- Fixes for FeatureFlagsViewController row animations.

## [0.0.2] - 2018-10-25
### Changed
- Making scheme shared to support Carthage.

## [0.0.1] - 2018-10-25
### Added
- Initial release.