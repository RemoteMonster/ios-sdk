[![Pod version](https://badge.fury.io/co/RemoteMonster.svg)](https://cocoapods.org/pods/RemoteMonster)

# RemoteMonster iOS SDK

RemoteMonster - Livecast Management in the Cloud

* [Website](https://remotemonster.com)

## Get SDK

### Package Manager - Cocoapods 1.9.0 or higher

```ruby
# Podfile
use_frameworks!
target 'MyApp' do
pod 'RemoteMonster', '~> 2.7.0'
end
```

```shell
# shell

pod install
```

```
사소한 변경사항, Hot fix의 경우 버전은 동일하며 빌드버전만 증가.
버전이 동일한 SDK를 사용시 기존 캐시 삭제 후 사용.
캐시위치 : ~/Library/Caches/CocoaPods/Pods/Release/RemoteMonster
프로젝트 : Podfile.lock, Pods 폴더 삭제
```

### Downloads

* [Downloads](https://github.com/RemoteMonster/ios-sdk/releases/)


## Examples
### Base Example( P2P Call, Cast )
* [source](https://github.com/RemoteMonster/ios-sdk/tree/master/examples/BaseExamples)

### Simple Conference
* [source](https://github.com/RemoteMonster/ios-sdk/tree/master/examples/SimpleConference)

### External Sample Capturer
* [source](https://github.com/RemoteMonster/ios-sdk/tree/master/examples/RemonCapturer)

### Full features
* [source](https://github.com/RemoteMonster/ios-sdk/tree/master/examples/full)

## Documents

* [Guides](https://docs.remotemonster.com/)
* [API Reference](https://remotemonster.github.io/ios-sdk/)

## Changelog

* [Changelog](https://github.com/RemoteMonster/ios-sdk/blob/master/CHANGELOG.md)
