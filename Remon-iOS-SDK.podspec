Pod::Spec.new do |s|
  s.name             = 'Remon-iOS-SDK'
  s.version          = '2.002'
  s.summary          = 'RemoteMonster Broadcast library with WebRTC'
  s.homepage         = 'https://remotemonster.com'
  #s.license          = 'BSD'
  s.author           = { 'RemoteMonster' => 'remotemonster@remotemonster.com' }
  s.source           = { :git => 'https://github.com/RemoteMonster/ios-sdk.git', :tag => '2.002' }
  s.platform     = :ios, '9.1'

  s.vendored_frameworks = 'remonios.framework'
  s.dependency 'GoogleWebRTC', '1.1.22700'
  # s.dependency 'Remon-WebRTC-iOS', '~> 1.0116'
end
