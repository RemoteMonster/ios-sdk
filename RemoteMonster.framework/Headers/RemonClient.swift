//
//  RemonClient.swift
//  RemoteMonster
//
//  Created by Chance Kim on 26/09/2019.
//  Copyright © 2019 Remote Monster. All rights reserved.
//

import Foundation


/**
통화(RemonCall), 방송(RemonCast) 공통 클래스
*/
@objc(RemonClient)
@IBDesignable
public class RemonClient:NSObject, RemonControllerBlockSettable {
    var controller: RemonClientController? = nil
    var currentRemonState:RemonState?
        
    internal var channelType:RemonChannelType = .p2p
    internal var autoReJoin_:Bool = false
    internal var firstInit:Bool = false
    internal var sendonly:Bool = false
    internal var tryReConnecting:Bool = false
    
    /** 연결이 완료 된 후 로컬 비디오 캡쳐를 자동으로 시작 할 지 여부 */
    public var autoCaptureStart:Bool = true
    
    /** debug mode.  default is false */
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
    

    /// 갭처러 객체
    public var localCapturer: RTCVideoCapturer? {
        get {
            return RemonCapturerManager.getInstance().videoCapturer
        }
    }
    

    // IBInspectable
    /** video codec H264 | VP8. default is H264 */
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
    @IBInspectable public var serviceId:String = ""
    
    /// 서비스키
    @IBInspectable public var serviceKey:String = ""
    
    /// 서비스 토큰
    @IBInspectable public var serviceToken:String = ""
    
    /// rest api 주소
    @IBInspectable public var restUrl:String = RemonConfig.REMON_REST_HOST_URL
    
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
    
    
    /// 시뮬레이터에서 사용할 동영상 파일명
    @IBInspectable public var videoFilePathForSimulator:String?
    
    
    internal override init() {
        print("[RemonClient.init]")
        super.init()
        self.controller = RemonClientController()
    }
    
    
    deinit {
        print("[RemonClient.deinit]")
    }
    
    
    // deprecated
    @available(*, deprecated, message: "use localCapturer" )
    public var localCameraCapturer:RTCCameraVideoCapturer?
    
    /// 외부 캡처러 사용시 프레임 데이터를 전달할 객체
    @available(*, deprecated, message: "use localCapturer" )
    public var localSampleCapturer:RemonSampleCapturer?
    
    // deprecated : 과거 RemonDelegate를 클라이언트에 직접 처리할때 사용된 코드
    @available(*, deprecated, message: "use callback functions")
    public weak var legacyDelegate: RemonDelegate?
    
    // preview 요소 deprecated. 카메라 프리뷰는 실제 전송될 화면과 다를수 있어 의미가 없음. localView 사용
    @available(*, deprecated, message: "use localView")
    public weak var localPreView:UIView?
}

/**
 클라이언트에서 호출하는 메쏘드들에 대한 인터페이스 확장 클래스
 */
extension RemonClient {
    
    /**
     */
    @objc func getCurrentRemonState() -> Int {
        if let status = self.currentRemonState {
            return status.rawValue
        } else {
            return RemonState.CLOSE.rawValue
        }
    }
    
    /** 현재 상태를 문자열로 얻어옵니다.
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
    
    /**
     원격지 사운드 켜거나 끄기
     */
    @objc public func setRemoteAudioEnabled(isEnabled:Bool = true) -> Void {
        controller?.setRemoteAudioEnabled(isEnabled: isEnabled)
    }
    
    /**
     로컬 사운드 켜거나 끄기
     */
    @objc public func setLocalAudioEnabled(isEnabled:Bool = true ) -> Void {
        controller?.setLocalAudioEnabled(isEnabled: isEnabled)
    }
    
    /**
        로컬 비디오 켜거나 끄기
     */
    @objc public func setLocalVideoEnabled(isEnabled:Bool = true ) -> Void {
        controller?.setLocalVideoEnabled(isEnabled: isEnabled)
    }
    
    /**
        원격지 비디오 켜거나 끄기
     */
    @objc public func setRemoteVideoEnabled(isEnabled:Bool = true) -> Void {
        controller?.setRemoteAudioEnabled(isEnabled: isEnabled)
    }
    
    /**
     로컬 비디오(카메라) 시작
     로컬 비디오를 사용하는 모든 연결에 영향이 있으므로, 특정 연결된 세션의 비디오를 켜거나 끄는 경우
     setLocalVideoEnabled( isEnabled: true ) 메쏘드 사용.
     */
    @objc public func startLocalVideoCapture(completion:@escaping ()->Void) -> Bool {
        return controller?.startLocalVideoCapture(completion: completion) ?? false
    }
    
    /**
     로컬 비디오(카메라) 중지
     */
    @objc public func stopLocalVideoCapture() -> Bool {
        return controller?.stopLocalVideoCapture() ?? false
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
        return controller?.switchCamera( isMirror:isMirror, isToggle:isToggle) ?? false
    }
    
    /**
     볼륨설정
     */
    @objc public func setVolume(volume:Float) -> Void {
        controller?.setVolume( volume: volume)
    }
    
    /**
     채널 목록 요청
     */
    public func fetchChannel(type:RemonSearchType, complete: @escaping (_ error:RemonError?, _ results:Array<RemonSearchResult>?)->Void) {
        RemonClientController.fetchChannel(client: self, type: type, complete: complete)
    }
    
    @objc public func startDump(withFileName: String, maxSizeInBytes:Int64) -> Void {
        controller?.startDump(withFileName: withFileName, maxSizeInBytes: maxSizeInBytes)
    }
    
    @objc public func stopDump() -> Void {
        controller?.stopDump()
    }
    
    @objc public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, avPreset:REMON_AECUNPACK_PRESET, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonClientController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, avPreset: avPreset, progress: progress )
    }
    
    @objc public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonClientController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, progress: progress)
    }
    
    
    public func showLocalVideo() -> Void {
        self.controller?.showLocalVideo(client: self)
    }
    
    
    
    // android 와 인터페이스 맞추기 위해 deprecated
    @available(*, deprecated, message: "Use setRemoteAudioEnabled( isEnabled: Bool )")
    @objc public func muteRemoteAudio(mute:Bool = true) -> Void {
        controller?.setRemoteAudioEnabled(isEnabled: !mute)
    }
    
    // android 와 인터페이스 맞춤
    @available(*, deprecated, message: "Use setLocalAudioEnabled( isEnabled: Bool )")
    @objc public func muteLocalAudio(mute:Bool = true) -> Void {
        controller?.setLocalAudioEnabled(isEnabled: !mute)
    }
    

    @available(*, deprecated, message: "Use setRemoteVideoEnabled( isEnabled: true)")
    @objc public func startRemoteVideoCapture() -> Void {
        controller?.setRemoteVideoEnabled(isEnabled: true)
    }
    
    @available(*, deprecated, message: "Use setRemoteVideoEnabled( isEnabled: false)")
    @objc public func stopRemoteVideoCapture() -> Void {
        controller?.setRemoteAudioEnabled(isEnabled: false)
    }
    
}



extension RemonClient {
    //set oberserver block
    internal func onFetchChannels(block:@escaping RemonArrayBlock) { controller?.observerBlock.fetchRemonChannelBlock = block}
    
    /** 채널 생성 후 호출되는 콜백 */
    internal func onCreate(block_:@escaping RemonStringBlock) { controller?.observerBlock.createRemonChannelBlock = block_}
    
    /** 에러 콜백 */
    public func onError(block:@escaping RemonErrorBlock) { controller?.observerBlock.errorRemonBlock = block}
    
    /** 초기화 콜백 */
    @objc public func onInit(block:@escaping RemonVoidBlock) { controller?.observerBlock.initRemonBlock = block}
    
    /** Peer간 접속 완료 콜백. webrtc 접속이 완료된 이후에 호출 */
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





extension RemonClient {
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

    @available(*, deprecated, message: "use localRTCEAGLVideoView")
    public var localRTCCameraPreviewView:RemonCameraPreviewView? {
        get {
            return nil; //controller?.remonView?.localRTCCameraPreviewView
        }
    }
}





//
extension RemonClient {
    /** sdk 의 기본 오디오 설정
     - Parameters
     + category: AVAudioSession.Category
     + mode: AVAudioSession.Mode
     + options: AVAudioSession.CategoryOptions
     */
    public static func setAudioSessionConfiguration(
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options:AVAudioSession.CategoryOptions) {
        
        // webrtc 전역 오디오세션 카테고리 설정
        let ac = RTCAudioSessionConfiguration.webRTC()
        ac.category = category.rawValue
        ac.mode = mode.rawValue
        ac.categoryOptions =  options
        
        //ac.sampleRate = 44100
        RTCAudioSessionConfiguration.setWebRTC(ac)
        
        #if DEBUG
        print("[RemonClient] setAudioSessionConfiguration: category=\(ac.category)")
        print("[RemonClient] setAudioSessionConfiguration: mode=\(ac.mode)")
        print("[RemonClient] setAudioSessionConfiguration: options=\(ac.categoryOptions)")
        #endif
 
        let session = RTCAudioSession.sharedInstance()
       
        session.lockForConfiguration()
        do {
            try session.setConfiguration(ac)
        } catch let error as NSError {
            print("[RemonClient] setAudioSessionConfiguration: ** Error RTCAudioSessionConfiguration", error.localizedDescription)
        }
        session.unlockForConfiguration()
        //
    }
}
