Pod::Spec.new do |s|
  s.name         = "Remon-WebRTC-iOS"
  s.version      = "1.0116"
  s.summary      = "WebRTC SDK for iOS"
  s.description  = <<-DESC
    WebRTC is a free, open project that provides browsers and mobile
    applications with Real-Time Communications (RTC) capabilities via simple
    APIs. The WebRTC components have been optimized to best serve this purpose.
                   DESC
  s.homepage     = "http://webrtc.org/"
  s.license      = "BSD"
  s.author       = "Google Inc."
  s.source       = { :git => "https://github.com/RemoteMonster/ios-sdk.git", :tag => "0.1.162" }
  s.platform     = :ios, "9.1"


  s.vendored_frameworks = "remonios.0.1.16/WebRTC.framework"
end