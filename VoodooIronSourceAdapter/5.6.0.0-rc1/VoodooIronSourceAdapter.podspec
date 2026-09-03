Pod::Spec.new do |s|
	s.name = 'VoodooIronSourceAdapter'
	s.version = '5.6.0.0-rc1'
	s.summary = "Voodoo Adapter"
	s.description = "Use this adapter to show Voodoo ads"
	s.homepage = "http://www.is.com/"
	s.license = { :type => "Commercial", :text => "https://platform.ironsrc.com/partners/terms-and-conditions-new-user" }
	s.author = {
	  "IronSource" => "http://www.is.com/contact/"
	}
	s.source = {
	  :http => "https://framework.voodoo-adn-dev.com/iOS/adapter/LevelPlay/5.6.0.0-rc1/Adapter.zip"
	}
	s.platform = [:ios, "14.0"]
	s.swift_versions = "5.0"
  
	s.source_files = "ISVoodooAdapter/ISVoodooAdapter.xcframework/**/*.{h,m}"
	s.public_header_files = "ISVoodooAdapter/ISVoodooAdapter.xcframework/**/*.h"
	s.preserve_paths = "ISVoodooAdapter/ISVoodooAdapter.xcframework"
	s.vendored_frameworks = "ISVoodooAdapter/ISVoodooAdapter.xcframework"
  
	s.pod_target_xcconfig = {
	  "VALID_ARCHS" => "arm64 x86_64",
	  "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64"
	}
  
	s.dependency 'IronSourceSDK/Ads', '~> 9.0'
	s.dependency 'VoodooAdn', '>= 4.30.0-rc1'
  end