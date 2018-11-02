# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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