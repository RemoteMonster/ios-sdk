//
//  RemonIBController.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit



/**
 InterfaceBuilder와 클라이언트에서 사용하는 메쏘드들을 정의한 인터페이스 클래스.
 접속전 서비스별로 각 프로퍼티를 설정할 수 있음.
 RemonCall, RemonCast는 RemonIBController의 하위 클래스로 동일하게 사용.
 별도의 config 정보가 없을 경우 지정된 값이 사용되며, config를 통한 설정시에는 config 값으로 설정됨.
 */
@objc(RemonIBController)
@IBDesignable
public class RemonIBController:NSObject, RemonControllBlockSettable {

    var controller: RemonController? = nil
    
    // public
    // deprecated : 뷰 설정 작업을 직접 진행하는 경우에 사용
    public weak var legacyDelegate: RemonDelegate?
    
    /** 연결이 완료 된 후 로컬 비디오 캡쳐를 자동으로 시작 할 지 여부 */
    public var autoCaptureStart:Bool = true
    
    
    /**debug mode.  default is false*/
    public var debugMode:Bool = false
    
    @objc public var remonConfig:RemonConfig?
    
    @objc public var volumeRatio:Double = 1.0 {
        didSet {
            if (self.volumeRatio > 1.0) {
                self.volumeRatio = 1.0
            } else if (self.volumeRatio < 0.0) {
                self.volumeRatio = 0.0
            }
            controller?.setAudioVolume(ratio: self.volumeRatio)
        }
    }
    
    
    
    @objc public var userMeta:String = "" {
        didSet {
            if let config = self.remonConfig {
                config.userMeta = userMeta
            }
        }
    }
    
    
    @objc public var showRemoteVideoStat = false {
        didSet(isShow) {
            controller?.remonView?.showRemoteVideoStat = self.showRemoteVideoStat
        }
    }
    
    @objc public var showLocalVideoStat = false {
        didSet(isShow) {
            controller?.remonView?.showLocalVideoStat = self.showLocalVideoStat
        }
    }
    
    /// 외부 캡처러 사용 여부 설정
    @objc public var useExternalCapturer:Bool = false
    @objc public var channelID:String?
    public var localCameraCapturer:RTCCameraVideoCapturer? {
        get {
            return controller?.localCameraCapturer
        }
    }
    
    /// 외부 캡처러 사용시 프레임 데이터를 전달할 객체
    public var localSampleCapturer:RemonSampleCapturer? {
        get {
            return controller?.localSampleCapturer
        }
    }
    
    var currentRemonState:RemonState?
    

    internal override init() {
        print("[RemonIBController.init]")
        super.init()
        if self.controller != nil {
            self.controller?.cleanup()
            self.controller = nil
        }
        
        self.controller = RemonController(client: self)
    }
    
    
    deinit {
        print("[RemonIBController.deinit]")
    }
    


    
    
    internal var channelType:RemonChannelType = .p2p
    internal var autoReJoin_:Bool = false
    internal var firstInit:Bool = false
    internal var sendonly:Bool = false
    internal var tryReConnecting:Bool = false
    
    
    
    // IBInspectable
    /**video codec H264 | VP8. default is H264 */
    @IBInspectable public var videoCodec:String = "H264"
    
    
    /// 오디오 전용 여부 선택
    @IBInspectable public var onlyAudio:Bool = false
    
    /// 비디오 가로 크기
    @IBInspectable public var videoWidth:Int = 640
    
    /// 비디오 세로 크기
    @IBInspectable public var videoHeight:Int = 480
    
    /// 초당 프레임 수
    @IBInspectable public var fps:Int = 24
    
    /// 서비스 아이디
    @IBInspectable public var serviceId:String?
    
    /// 서비스키
    @IBInspectable public var serviceKey:String?
    
    /// rest api 주소
    @IBInspectable public var restUrl:String = RemonConfig.REMON_REST_URL
    
    
    /// 웹소켓 주소
    @IBInspectable public var wsUrl:String = RemonConfig.REMON_WS_URL
    
    /// log 서버 주소
    @IBInspectable public var logUrl:String = RemonConfig.REMON_REST_LOG_SERVER
    
    
    
    
    
    
    
    /// 전면 카메라 시작
    @IBInspectable public var frontCamera:Bool = true {
        didSet( isFront ) {
            if let config = self.remonConfig {
                config.frontCamera = isFront
            }
        }
    }
    
    /// 카메라 화면 미러모드 동작여부, 화면만 미러로 동작하며, 실제 데이터는 정상 전송
    @IBInspectable public var mirrorMode:Bool = false {
        didSet(isMirror) {
            if let config = self.remonConfig {
                config.mirrorMode = isMirror
            }
        }
    }
    
    /**
    최종 output 프레임 고정여부.
    true 인 경우 연결시의 방향으로 출력 사이즈가 고정됩니다.
    false 인 경우 앱이 지원하는 방향으로 회전이 이루어집니다.
    단, 앱이 하나의 방향만을 지원하는 경우 회전이 발생하지 않습니다.
     */
    @IBInspectable public var fixedCameraRotation:Bool = false
    
    
    // @IBInspectable public var autoReJoin:Bool
    // @IBInspectable public var audioType:RemonAudioMode

    
    // IBOutlet
    @IBOutlet dynamic public weak var remoteView:UIView?
    @IBOutlet dynamic public weak var localView:UIView?
    @IBOutlet dynamic public weak var localPreView:UIView?
    
    
}



/**
 클라이언트에서 호출하는 메쏘드들에 대한 인터페이스 확장 클래스
 */
extension RemonIBController {
    
    /**
     */
    @objc func getCurrentRemonState() -> Int {
        if let status = self.currentRemonState {
            return status.rawValue
        } else {
            return RemonState.CLOSE.rawValue
        }
    }
    
    /**
     */
    @objc public func getCurruntStateString() -> String {
        let stateString = "UNKNOWN"
        if let state = self.currentRemonState  {
            switch state {
            case RemonState.CLOSE:
                return "CLOSE"
            case RemonState.CONNECT:
                return "COMPLETE"
            case RemonState.COMPLETE:
                return "COMPLETE"
            case RemonState.CREATE:
                return "CREATE"
            case RemonState.FAIL:
                return "FAIL"
            case RemonState.ICEDISCONNECT:
                return "ICEDISCONNECT"
            case RemonState.INIT:
                return "INIT"
            case RemonState.EXIT:
                return "EXIT"
            default:
                return stateString
            }
        }
        
        return stateString
    }
    
    /**
     webrtc 연결 종료
     */
    @objc public func closeRemon() {
        controller?.closeRemon()
    }
    
    
    /**
     대역폭 전환
     */
    public func switchBandWidth(bandwidth:RemonBandwidth) {
        controller?.switchBandWidth(bandwidth: bandwidth)
    }
    
    @objc public func objc_switchBandWidth(bandwidth:objc_RemonBandwidth) {
        controller?.objc_switchBandWidth(bandwidth: bandwidth)
    }
    
    @objc func setAudioToSpeaker(){
        controller?.setAudioToSpeaker()
    }
    
    
    /**
     원격지 사운드 켜거나 끄기
     */
    @objc public func muteRemoteAudio(mute:Bool = true) -> Void {
        controller?.muteRemoteAudio(mute: mute)
    }
    
    /**
     로컬 사운드 켜거나 끄기
     */
    @objc public func muteLocalAudio(mute:Bool = true) -> Void {
        controller?.muteLocalAudio(mute: mute)
    }
    
    @objc public func stopLocalVideoCapture() -> Bool {
        return controller?.stopLocalVideoCapture() ?? false
    }
    
    /**
     로컬 비디오(카메라) 캡처 시작
     */
    @objc public func startLocalVideoCapture(completion:@escaping ()->Void) -> Bool {
        return controller?.startLocalVideoCapture(completion: completion) ?? false
    }
    
    
    @objc public func startRemoteVideoCapture() -> Void {
        controller?.startRemoteVideoCapture()
    }
    
    @objc public func stopRemoteVideoCapture() -> Void {
        controller?.stopRemoteVideoCapture()
    }
    
    /**
     * 채널이 연결된 상태에서 상대편에게 메시지를 전달한다.
     */
    @objc public func sendMessage(message:String){
        controller?.sendMessage(message: message)
    }
    
    /**
     카메라 전환
     현재 카메라의 미러모드를 전환하거나, 전후면 카메라를 전환한다
     -Parameters:
     +isMirror: 미러모드 적용 여부
     +isToggle: 카메라 전면,후면 전환 여부
     
     -Return:변경된 카메라가 전면이면 true, 후면이면 false
     */
    @objc public func switchCamera( isMirror:Bool = false, isToggle:Bool = true) -> Bool {
        return controller?.switchCamera(client: self, isMirror:isMirror, isToggle:isToggle) ?? false
    }
    

    /**
     볼륨설정
     */
    @objc public func setVolume(volume:Float) -> Void {
        controller?.setVolume(client: self, volume: volume)
    }
    
    
    /**
     채널 목록 요청
     */
    public func fetchChannel(type:RemonSearchType, complete: @escaping (_ error:RemonError?, _ results:Array<RemonSearchResult>?)->Void) {
        controller?.fetchChannel(client: self, type: type, complete: complete)
    }
    
    public func fetchChannel(type:RemonSearchType, isTest:Bool, complete: @escaping (_ error:RemonError?, _ results:Array<RemonSearchResult>?)->Void) {
        controller?.fetchChannel(client:self, type: type, isTest: isTest, complete: complete)
    }
    
    
    @objc public func startDump(withFileName: String, maxSizeInBytes:Int64) -> Void {
        controller?.startDump(withFileName: withFileName, maxSizeInBytes: maxSizeInBytes)
    }
    
    @objc public func stopDump() -> Void {
        controller?.stopDump()
    }
    
    @objc public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, avPreset:REMON_AECUNPACK_PRESET, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, avPreset: avPreset, progress: progress )
    }
    
    @objc public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, progress: progress)
    }
}

extension RemonIBController {
    //set oberserver block
    internal func onFetchChannels(block:@escaping RemonArrayBlock) { controller?.observerBlock.fetchRemonChannelBlock = block}
    internal func onCreate(block_:@escaping RemonStringBlock) { controller?.observerBlock.createRemonChannelBlock = block_}
    
    /** 에러 콜백 */
    public func onError(block:@escaping RemonErrorBlock) { controller?.observerBlock.errorRemonBlock = block}
    
    /** 초기화 콜백 */
    @objc public func onInit(block:@escaping RemonVoidBlock) { controller?.observerBlock.initRemonBlock = block}
    
    /** 접속 완료 콜백. webrtc 접속이 완료된 이후에 호출 */
    @objc public func onComplete(block:@escaping RemonVoidBlock) { controller?.observerBlock.completeRemonChannelBlock = block}
    
    /** 연결 종료 콜백 */
    @objc public func onClose(block:@escaping RemonCloseBlock) {controller?.observerBlock.closeRemonChannelBlock = block}
    
    
    @objc public func onDisConnect(block:@escaping RemonStringBlock) { controller?.observerBlock.disConnectRemonChannelBlock = block}
    
    /** 메시지 수신 콜백 */
    @objc public func onMessage(block:@escaping RemonStringBlock) { controller?.observerBlock.messageRemonChannelBlock = block}
    
    @objc public func onObjcError(block:@escaping ((_:NSError) -> Void)) { controller?.observerBlock.objc_errorRemonBlock = block}
    @objc public func onRetry(block:@escaping ((_:Bool) -> Void)) { controller?.observerBlock.tryReConnect = block}
    @objc public func onRemonStatReport(block:@escaping (_:RemonStatReport)->Void) {controller?.observerBlock.remonStatBlock = block}
    
    /** 원격측 비디오 사이즈 변경시 호출 */
    @objc public func onRemoteVideoSizeChanged(block: @escaping (_ remoteView:UIView?, _ videoSize:CGSize) -> Void) {
        controller?.observerBlock.didChangeRemoteVideoSize = block
    }
    
    /** 로컬 비디오 사이즈 변경시 호출 */
    @objc public func onLocalVideoSizeChanged(block: @escaping (_ localView:UIView?, _ videoSize:CGSize) -> Void) {
        controller?.observerBlock.didChangeLocalVideoSize = block
    }
}

extension RemonIBController {
    public var remoteRTCEAGLVideoView:RTCEAGLVideoView?{
        get {
            return controller?.remonView?.remoteRTCEAGLVideoView
        }
    }
    
    public var localRTCEAGLVideoView:RTCEAGLVideoView? {
        get {
            return controller?.remonView?.localRTCEAGLVideoView
        }
    }
    
    public var localRTCCameraPreviewView:RemonCameraPreviewView? {
        get {
            return controller?.remonView?.localRTCCameraPreviewView
        }
    }
}
