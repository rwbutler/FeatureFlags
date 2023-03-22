//
//  TestVariationAssignmentTests.swift
//  FeatureFlags
//
//  Created by Ross Butler on 12/9/18.
//

import Foundation
import XCTest
@testable import FeatureFlags

/// Testing that the user is assigned to the correct A/B testing group.
class TestVariationTests: XCTestCase {

    func testWhenFeatureNotEnabledThatNotInTestVariationGroup() {
        let featureConfiguration =
        """
        [{
        "name": "Example A/B Test",
        "enabled": false,
        "test-biases": [50, 50],
        "test-variations": ["Group A", "Group B"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            var feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        feature.testVariationAssignment = 0.0
        XCTAssert(!feature.isTestVariation(.groupA), "Pass")
        XCTAssert(!feature.isTestVariation(.groupB), "Pass")
    }

    func testWhenFeatureABNotEnabledThatInTestVariationDisabled() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": false,
        "test-variations": ["Enabled", "Disabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            var feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        feature.testVariationAssignment = 0.0
        XCTAssert(!feature.isTestVariation(.enabled), "Pass")
        XCTAssert(feature.isTestVariation(.disabled), "Pass")
    }

    func testWhenFeatureABNotEnabledThatIsDisabled() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": false,
        "test-variations": ["Enabled", "Disabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            var feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        feature.testVariationAssignment = 0.0
        XCTAssert(!feature.isEnabled(), "Pass")
    }

    func testWhenTestVariationsAreEnabledAndDisabledThenTypeIsFeatureFlagAB() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": false,
        "test-variations": ["Enabled", "Disabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            let feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        XCTAssertEqual(feature.type, .featureTest(.featureFlagAB))
    }

    func testWhenTestVariationsAreEnabled_DisabledAndBiasesAre80_20ThenEnabledBiasIs80() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": true,
        "test-biases": [80, 20],
        "test-variations": ["Enabled", "Disabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            let feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        XCTAssertEqual(feature.testVariations.count, 2)
        XCTAssertEqual(feature.testBias(.enabled)?.rawValue, 80)
        XCTAssertEqual(feature.testBias(.disabled)?.rawValue, 20)
    }

    func testWhenTestVariationsAreDisabledAndEnabledThenTypeIsFeatureFlagAB() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": false,
        "test-variations": ["Disabled", "Enabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            let feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        XCTAssertEqual(feature.type, .featureTest(.featureFlagAB))
    }

    func testWhenTestVariationsAreDisabled_EnabledAndBiasesAre80_20ThenEnabledBiasIs20() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": true,
        "test-biases": [80, 20],
        "test-variations": ["Disabled", "Enabled"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            let feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        XCTAssertEqual(feature.testVariations.count, 2)
        XCTAssertEqual(feature.testBias(.enabled)?.rawValue, 20)
        XCTAssertEqual(feature.testBias(.disabled)?.rawValue, 80)
    }

    func testWhenTestVariationsAreAAndBThenTypeIsFeatureTestAB() {
        let featureConfiguration =
        """
        [{
        "name": "Example Feature A/B Test",
        "enabled": false,
        "test-variations": ["A", "B"]
        }]
        """
        let decoder = JSONDecoder()
        guard let featuresData = featureConfiguration.data(using: .utf8),
            let features = try? decoder.decode([Feature].self, from: featuresData),
            let feature = features.first else {
                XCTAssert(false, "Fail")
                return
        }
        XCTAssertEqual(feature.type, .featureTest(.ab))
    }
}
