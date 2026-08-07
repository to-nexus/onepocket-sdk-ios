Pod::Spec.new do |s|
  s.name             = 'CROSSxSDK'
  s.version          = '2.3.2'
  s.summary          = 'CROSSx SDK for iOS'
  s.description      = <<-DESC
                       CROSSx SDK provides secure authentication and blockchain functionality for iOS applications.
                       DESC

  s.homepage         = 'https://github.com/to-nexus/onepocket-sdk-ios'
  s.license          = { :type => 'MIT' }
  s.author           = { 'to-nexus' => 'contact@to-nexus.com' }
  s.source           = { :git => 'https://github.com/to-nexus/onepocket-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  
  s.vendored_frameworks = 'CROSSxSDK.xcframework'
  s.resource_bundles = {
    'crossx-sdk-ios_CROSSxCoreSDK' => ['Resources/CROSSxCoreSDKResources/Resources/**/*']
  }
  
  s.dependency 'CrossWebAuthKit', '~> 2.3.2'
end
