## 2.1.3
- add builtInReceiverOverideToSpeaker IBInspectable property
  - default is true
  - If you want to change the output device
  ```
  // in runtime!!!
  remonCall.builtInReceiverOverideToSpeaker = !remonCall.builtInReceiverOverideToSpeaker
  ```

## 2.1.6
- fix! onComplete() Duplicate invocation 

## 2.1.8
- support VP8 and simulcast
- stat log

## 2.1.9
- change access control of RemonStatReport

## 2.2.0
- bugfix objc에서 2.0를 사용이 안되는 문제 수정.

## 2.2.1
- objc supported

## 2.2.2
- objc supported (RemonStatReport)

## 2.2.3
- add objc error callback
```
[self.remonCast onObjcErrorWithBlock:^(NSError * _Nonnull error) {
    // Do something
}];
```

## 2.2.4
- bug fix

## 2.2.5
- sorry .. my mistake

## 2.2.7
- swift 4.2 supported

## 2.2.8
- bug fix

## 2.2.9
- bug fix
  - do not called 'onClose()'

## 2.3.0
- objc 에서 녹음 기능 지원

## 2.3.4
- getHealthRating 호출시 비정상 종료 되는 문제 수정
- getHealthRating가 objc 환경에서 동작 하도록 수정

## 2.3.6
- add unpackAecDump 
```
RemonCall.unpackAecDump(dumpName: "audio.aecdump", resultFileName: "unpack.m4a", avPreset:.MP4MEDIUM, progress:{(_, _) in }
```

## 2.3.7
- hotfix unpackAecDump()

## 2.3.8
- support mute at objc

## 2.3.9
- change videoView access controll

## 2.4.0.1
- add observer method
  - onRemoteVideoSizeChanged
  - onLocalVideoSizeChanged

## 2.4.13
- bug fix
  - No crash without a channel id

## 2.4.20
- change default audio session category
- change health log cycle
- change health log rule

## 2.4.38
- add property volumeRatio at RemonController
- add property userMete at RemonConfig
- add callback func onRetry at RemonController

## 2.4.43
- add property useExternalCapturer at RemonController And RemonConfig
- add Class RemonSampleCapturer
  - Used through localExternalCaptureDelegator at RemonController

## 2.4.44
- add getCurrentStateString()
- bug fix
  - support switchCameta for objc

## 2.4.44
- bug fix

## 2.4.48
- modify debug log for issue tracking
- bug fix
    - sockect reconnect error

## 2.4.49
- Change time to add videoRender at videoTrack
- Change call interval of onRemonStatReport()

## 2.4.491
- bug fix 
  - unpackAecDump(resultFileName: "record.mp4", avPreset: .MP4MEDIUM, progress: (error, state) -> Void)

## 2.4.491
- Change REMON_AECUNPACK_STATE

## 2.4.50
- support swift 5

## 2.5.0
- support swift 5
- removed AVAudioSession controll code