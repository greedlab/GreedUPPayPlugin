Pod::Spec.new do |s|

  s.name = "GreedUPPayPlugin"
  s.version = "3.3.0.1"
  s.license = "MIT"
  s.summary = "IOS版银联手机控件支付开发"
  s.homepage = "https://github.com/greedlab/GreedUPPayPlugin"
  s.author       = { "Bell" => "bell@greedlab.com" }
  s.source       = { :git => "https://github.com/greedlab/GreedUPPayPlugin.git", :tag => s.version }
  s.platform = :ios
  s.requires_arc = true
  s.frameworks = 'CFNetwork','SystemConfiguration','Security'
  s.libraries = 'z'
  s.source_files = 'paymentcontrol/inc/*.h'
  s.vendored_libraries = 'paymentcontrol/libs/libPaymentControl.a'
end
