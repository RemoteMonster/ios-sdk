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
사소한 변경사항의 경우 동일한 버전으로 빌드버전만 증가합니다.
기존 버전으로 install 된 경우 새로 업데이트된 SDK를 사용할 수 없습니다. 
저장소의 SDK Build Version 과 다른 버전이 설치되는 경우 cocoapods 캐시를 삭제하고 다시 설치하시기 바랍니다.
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
