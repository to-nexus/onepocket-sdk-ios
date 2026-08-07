Pod::Spec.new do |s|
  s.name             = 'CrossWebAuthKit'
  s.version          = '2.3.3-beta.1'
  s.summary          = 'Web Authentication Kit for CROSSx SDK'
  s.description      = <<-DESC
                       CrossWebAuthKit provides web-based authentication functionality for CROSSx SDK.
                       DESC

  s.homepage         = 'https://github.com/to-nexus/onepocket-sdk-ios'
  s.license          = { :type => 'MIT' }
  s.author           = { 'to-nexus' => 'contact@to-nexus.com' }
  s.source           = { :git => 'https://github.com/to-nexus/onepocket-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '12.0'
  
  s.vendored_frameworks = 'CrossWebAuthKit.xcframework'
end
