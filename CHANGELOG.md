# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2019-12-16
### Added
Feature flags may now have a `description` field in JSON which will display in FeatureFlagsViewController providing more context around what the feature flag is used for.

## [2.1.2] - 2019-12-02
### Changed
- Stopped `FeatureFlagsViewController` reloading data by default on open as this prevents the user from inspecting the current state of feature flag by resetting their values. Instead feature flags will only be refreshed if `shouldRefresh` explicitly set `true` or refreshed by user via the UI. Additionally, feature flags will be refreshed in the event that `FeatureFlags.configuration` is nil.

## [2.1.1] - 2019-10-02
### Changed
- Fixed an issue with encoding a feature using `Codable` whereby the `labels` property would not be encoded.

## [2.1.0] - 2019-10-01
### Added
- Additional macros `TEST_VARIATION` and `USER_IS_IN_TEST_VARIATION` for interoperability with Objective-C.

## [2.0.0] - 2019-03-29
### Changed
- Updated from Swift 4.2 to Swift 5.

## [1.7.5] - 2019-03-07
### Added
- It is now possible to instantiate and add a feature flag programmatically.

## [1.7.4] - 2019-03-01
### Added
- Added method `isNoLongerUnderDevelopment()` which can be used to flush development status of a feature flag when development work on a feature is complete.

## [1.7.3] - 2019-01-28
### Changed
- Made `isDevelopment` flag less aggressive so it is possible to return development feature flags to regular feature flags once development complete. If `is-development` is set in either remote or local configuration then the flag will remain a development flag.

## [1.7.2] - 2019-01-18
### Changed
- Fixed an issue whereby feature flags were incorrectly being treated as unlock flags after being retrieved from persistence.

## [1.7.1] - 2019-01-18
### Changed
- Fixed a crash in the example app when pressing the action button.

## [1.7.0] - 2019-01-09
### Added
- Added unlock flags which can be used for unlocking (or locking) a feature permanently e.g. after the user has made an in-app purchase or a feature needs to be permanently unlocked programmatically following a certain date. To unlock or lock, optionally specify a default value for `unlocked` in the JSON config and then call `unlock()` or `lock()` as required. Use `isUnlocked()` to check current state.

## [1.6.1] - 2019-01-09
### Changed
- Relaxing SwiftLint requirement from an error to a warning as this prevents consumers from building where SwiftLint is not installed.

## [1.6.0] - 2019-01-04
### Added
- Added an option to the `FeatureFlagsViewController` action sheet to refresh features.

## [1.5.3] - 2019-01-03
### Changed
- Fixed an edge case issue whereby if a feature flag was not defined in remote configuration but defined locally and then retrieved from disk it would returned as a `Feature On/Off A/B Test` rather than as a standard `Feature Flag`.

## [1.5.2] - 2019-01-03
### Changed
- Lowered deployment target to iOS 9.0.

## [1.5.1] - 2019-01-02
### Changed
- Enabled `Allow app extension API only` in target deployment info. Presenting `UIViewController` must now be passed by caller when presenting `FeatureFlagsViewController`.
- Introduced a `Test.Variation` of `unassigned` for use in the event that a logic error occurs and a test variation cannot be assigned to a feature.

## [1.5.0] - 2018-12-21
### Changed
- Now possible to present FeatureFlagsViewController without a close button.
- Fixed an issue where test variation assignments were not stored in the sitatuation where no remote data or cached data present (first launch scenario).

## [1.4.0] - 2018-12-17
### Changed
- Swipe to delete on FeatureFlagsViewController now deletes the feature rather than clearing cache now that cache can be cleared via the action button. Note: If the feature is still present in the JSON then it will re-created on refresh.
- Updated refresh completion closures so that they are only invoked after the new configuration information is available.

## [1.3.1] - 2018-12-06
### Changed
- Switched method of random number generation from `drand48() * 100` to `Double.random(in: 0..<100.0)`.

## [1.3.0] - 2018-12-06
### Added
- Added `FeatureFlagsUI.autoRefresh` property to automatically refresh data from configuration when the app is foregrounded (defaults to `false`).
- Added ability to clear cache from `FeatureFlagsViewController`.
- Added convenience initializer to `Feature` allowing a Feature to be retrieved using `Feature(named: .myFeature)` rather than `Feature.named(.myFeature)`.

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