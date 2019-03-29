Pod::Spec.new do |s|
  s.name             = 'FeatureFlags'
  s.version          = '2.0.0'
  s.swift_version    = '5.0'
  s.summary          = 'Feature flagging, A/B testing, MVT and phased feature roll out for iOS.'
  s.description      = <<-DESC
FeatureFlags makes it easy to configure feature flags, A/B and MVT tests via a JSON file which may be bundled with your app or hosted remotely. For remotely-hosted configuration files, you may enable / disable features without another release to the App Store, update the percentages of users in A/B test groups or even roll out a feature previously under A/B test to 100% of your users once you have decided that the feature is ready for prime time.
                       DESC
  s.homepage         = 'https://github.com/rwbutler/FeatureFlags'
  s.screenshots     = 'https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-view-controller.png', 'https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-details-view-controller.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ross Butler' => 'github@rwbutler.com' }
  s.source           = { :git => 'https://github.com/rwbutler/FeatureFlags.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'FeatureFlags/Classes/**/*'
end
