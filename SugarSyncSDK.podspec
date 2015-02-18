#
# Be sure to run `pod lib lint SugarSyncSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SugarSyncSDK"
  s.version          = "1.0.0"
  s.summary          = "Objective C framework for the Sugar Sync API on iOS."
  s.homepage         = "https://github.com/PatrickNLT/sugarsync-ios"
  s.license          = 'MIT'
  s.authors           = 'Patrick Nollet', 'Bill Culp'
  s.source           = { :git => "https://github.com/PatrickNLT/sugarsync-ios.git" }

  s.platform     = :ios, '7.0'
  s.requires_arc = false
  s.library = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  s.source_files = 'SugarSyncSDK/SugarSyncSDK/**/*{.h,.m}'
  s.public_header_files = 'SugarSyncSDK/SugarSyncSDK/Public Headers/*.h'
  s.dependency 'KissXML', '~> 5.0'
end
