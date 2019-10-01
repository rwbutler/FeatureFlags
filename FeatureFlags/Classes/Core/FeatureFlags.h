//
//  FeatureFlags.h
//  FeatureFlags
//
//  Created by Ross Butler on 11/8/18.
//

#define FEATURE_IS_ENABLED(featureName) [FeatureFlagsAdapter isEnabled:featureName]
#define TEST_VARIATION(testName) [FeatureFlagsAdapter testVariation:testName]
#define TEST_VARIATION_LABEL(testName) [FeatureFlagsAdapter label:testName]
#define USER_IS_IN_TEST_VARIATION(testName, variationName) [FeatureFlagsAdapter userIsInTest:testName variation:variationName]
