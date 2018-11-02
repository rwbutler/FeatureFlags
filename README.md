![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-banner.png)

[![CI Status](http://img.shields.io/travis/rwbutler/FeatureFlags.svg?style=flat)](https://travis-ci.org/rwbutler/FeatureFlags)
[![Version](https://img.shields.io/cocoapods/v/FeatureFlags.svg?style=flat)](http://cocoapods.org/pods/Featureflags)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/FeatureFlags.svg?style=flat)](http://cocoapods.org/pods/FeatureFlags)
[![Platform](https://img.shields.io/cocoapods/p/FeatureFlags.svg?style=flat)](http://cocoapods.org/pods/FeatureFlags)

FeatureFlags makes it easy to configure feature flags, A/B and MVT tests via a JSON file which may be bundled with your app or hosted remotely. For remotely-hosted configuration files, you may enable / disable features without another release to the App Store, update the percentages of users in A/B test groups or even roll out a feature previously under A/B test to 100% of your users once you have decided that the feature is ready for prime time. 

- [Features](#features)
- [Installation](#installation)
	- [Cocoapods](#cocoapods)
	- [Carthage](#carthage)
- [Author](#author)
- [License](#license)
- [Additional Software](#additional-software)
	- [Frameworks](#frameworks)
	- [Tools](#tools)

## Features

- [x] Feature flags
- [x] A/B testing and MVT testing
- [x] Feature A/B testing (where a feature is enabled vs a control group without the feature)
- [x] Host your feature flags JSON configuration remotely allowing you to enable / disable features without releasing a new version of your app
- [x] Use an existing JSON file or host an entirely new configuration
- [x] Adjust the percentages of users in each test group remotely
- [x] Convert an A/B test into a feature flag once you have decided whether the feature test was a success i.e. rollout a feature to 100% of users
- [x] Visualise the state of your flags and tests using FeatureFlagsViewController in debug builds of your app

## Installation

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager which integrates dependencies into your Xcode workspace. To install it using [RubyGems](https://rubygems.org/) run:

```
gem install cocoapods
```

To install FeatureFlags using Cocoapods, simply add the following line to your Podfile:

```
pod "FeatureFlags"
```

Then run the command:

```
pod install
```

For more information [see here](https://cocoapods.org/#getstarted).

### Carthage

Carthage is a dependency manager which produces a binary for manual integration into your project. It can be installed via [Homebrew](https://brew.sh/) using the commands:

```
brew update
brew install carthage
```

In order to integrate FeatureFlags into your project via Carthage, add the following line to your project's Cartfile:

```
github "rwbutler/FeatureFlags"
```

From the macOS Terminal run `carthage update --platform iOS` to build the framework then drag `FeatureFlags.framework` into your Xcode project.

For more information [see here](https://github.com/Carthage/Carthage#quick-start).

## Author

Ross Butler

## License

FeatureFlags is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Additional Software

### Frameworks

* [Connectivity](https://github.com/rwbutler/Connectivity) - Improves on Reachability for determining Internet connectivity in your iOS application.
* [FeatureFlags](https://github.com/rwbutler/FeatureFlags) - Allows developers to configure feature flags, run multiple A/B or MVT tests using a bundled / remotely-hosted JSON configuration file.
* [Skylark](https://github.com/rwbutler/Skylark) - Fully Swift BDD testing framework for writing Cucumber scenarios using Gherkin syntax.
* [TailorSwift](https://github.com/rwbutler/TailorSwift) - A collection of useful Swift Core Library / Foundation framework extensions.
* [TypographyKit](https://github.com/rwbutler/TypographyKit) - Consistent & accessible visual styling on iOS with Dynamic Type support.

### Tools
* [Palette](https://github.com/rwbutler/TypographyKitPalette) - Makes your [TypographyKit](https://github.com/rwbutler/TypographyKit) color palette available in Xcode Interface Builder.


[Connectivity](https://github.com/rwbutler/Connectivity)          |  [FeatureFlags](https://github.com/rwbutler/FeatureFlags)          | [Skylark](https://github.com/rwbutler/Skylark) | [TypographyKit](https://github.com/rwbutler/TypographyKit) | [Palette](https://github.com/rwbutler/TypographyKitPalette)
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
[![Connectivity](https://github.com/rwbutler/Connectivity/raw/master/ConnectivityLogo.png)](https://github.com/rwbutler/Connectivity)   | [![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-logo.png)](https://github.com/rwbutler/FeatureFlags)   | [![Skylark](https://github.com/rwbutler/Skylark/raw/master/SkylarkLogo.png)](https://github.com/rwbutler/Skylark) |  [![TypographyKit](https://github.com/rwbutler/TypographyKit/raw/master/TypographyKitLogo.png)](https://github.com/rwbutler/TypographyKit) | [![Palette](https://github.com/rwbutler/TypographyKitPalette/raw/master/PaletteLogo.png)](https://github.com/rwbutler/TypographyKitPalette)


