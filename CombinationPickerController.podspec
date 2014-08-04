Pod::Spec.new do |s|
  s.name         = "CombinationPickerController"
  s.version      = "0.0.1"
  s.summary      = "iOS picker"
  s.homepage     = "https://github.com/opendream/CombinationPickerController"
  s.license      = "MIT"
  s.author    = "Opendream"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/opendream/CombinationPickerController.git", :tag => "0.0.2" }
  s.source_files  = 'CombinationPickerContoller', 'CombinationPickerContoller/**/*.{h,m}'  
  s.resources = ["**/*.png", "**/*.xib"]
  s.frameworks = "QuartzCore", "AssetsLibrary", "Foundation", "UIKit"
  s.requires_arc = true
  s.dependency "KxMenu", "~> 1"

end