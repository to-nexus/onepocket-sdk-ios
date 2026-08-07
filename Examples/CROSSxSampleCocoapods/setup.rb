#!/usr/bin/env ruby
#
# CROSSxSampleCocoapods 프로젝트 생성 스크립트
# CocoaPods의 의존성인 xcodeproj gem을 사용하여 .xcodeproj를 생성합니다.
#
# 사용법: ruby setup.rb
#

require 'xcodeproj'

PROJECT_NAME = 'CROSSxSampleCocoapods'
BUNDLE_ID    = 'com.nexus.crossxsample-cocoapods'
DEPLOY_TARGET = '15.0'

proj_path = File.join(__dir__, "#{PROJECT_NAME}.xcodeproj")

if File.exist?(proj_path)
  puts "기존 #{PROJECT_NAME}.xcodeproj 삭제 중..."
  FileUtils.rm_rf(proj_path)
end

puts "#{PROJECT_NAME}.xcodeproj 생성 중..."
project = Xcodeproj::Project.new(proj_path)

# ── App target ──────────────────────────────────────────────
target = project.new_target(
  :application,
  PROJECT_NAME,
  :ios,
  DEPLOY_TARGET
)

# ── Build configurations ────────────────────────────────────
debug_xcconfig   = File.join('Configurations', 'Debug.xcconfig')
release_xcconfig = File.join('Configurations', 'Release.xcconfig')

debug_ref   = project.new_file(debug_xcconfig)
release_ref = project.new_file(release_xcconfig)

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  config.build_settings['INFOPLIST_FILE'] = 'Resources/Info.plist'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOY_TARGET
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'

  case config.name
  when 'Debug'
    config.base_configuration_reference = debug_ref
  when 'Release'
    config.base_configuration_reference = release_ref
  end
end

# ── Source files ────────────────────────────────────────────
sources_group = project.main_group.new_group('Sources', 'Sources')

Dir.glob(File.join(__dir__, 'Sources', '*.swift')).sort.each do |path|
  file_ref = sources_group.new_file(File.basename(path))
  target.source_build_phase.add_file_reference(file_ref)
end

# ── Resources ───────────────────────────────────────────────
resources_group = project.main_group.new_group('Resources', 'Resources')

%w[Info.plist LaunchScreen.storyboard].each do |name|
  file_ref = resources_group.new_file(name)
  # Info.plist은 빌드 리소스에 추가하지 않음
  next if name == 'Info.plist'
  target.resources_build_phase.add_file_reference(file_ref)
end

# ── Configurations ──────────────────────────────────────────
config_group = project.main_group.new_group('Configurations', 'Configurations')
config_group.new_file('Debug.xcconfig')
config_group.new_file('Release.xcconfig')

# ── Podfile (참조용) ─────────────────────────────────────────
project.main_group.new_file('Podfile')

# ── Save ────────────────────────────────────────────────────
project.save

puts ""
puts "#{PROJECT_NAME}.xcodeproj 생성 완료!"
puts ""
puts "다음 단계:"
puts "  1. pod install"
puts "  2. open #{PROJECT_NAME}.xcworkspace"
