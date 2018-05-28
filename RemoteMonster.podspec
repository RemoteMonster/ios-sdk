Pod::Spec.new do |s|
  s.name             = 'RemoteMonster'
  s.version          = '2.0.5'
  s.summary          = 'RemoteMonster SDK'
  s.homepage         = 'https://remotemonster.com'
  s.license          = 'MIT'
  s.author           = { 'RemoteMonster' => 'remotemonster@remotemonster.com' }
  s.source           = { :git => 'https://github.com/RemoteMonster/ios-sdk.git', :tag => '2.0.5' }
  s.platform     = :ios, '9.1'
  s.documentation_url = 'https://remotemonster.github.io/ios-sdk/'

  s.vendored_frameworks = 'Remon.framework'
  s.dependency 'GoogleWebRTC', '1.1.22700'
end
