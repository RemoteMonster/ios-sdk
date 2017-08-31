Pod::Spec.new do |s|
  s.name             = "Remon-iOS-SDK"
  s.version          = "0.1.15"
  s.summary          = "Remon-IOS_SDK"
  s.homepage         = "https://remotemonster.com"
  s.license          = 'BSD'
  s.author           = { "RemoteMonster" => "remotemonster@remotemonster.com" }
  s.source           = { :git => "https://github.com/RemoteMonster/ios-sdk.git", :tag => "0.1.15" }
  s.social_media_url = 'https://community.remotemonster.com/'

  s.platform     = :ios, '9.1'

  s.vendored_frameworks = "remonios.framework"
  s.dependency 'WebRTC', '~> 60.10.18252'
end