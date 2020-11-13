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
public class RemonClient:NSObject {
    public override init() {
        print("[RemonClient.init]")
        super.init()
    }
    
    deinit {
        print("[RemonClient.deinit]")
    }
    
    
    
    
    internal var controller: RemonClientController = RemonClientController()
    @objc public var channelID:String? {
        get { self.controller.context.channelId }
    }
    @objc public var remonConfig:RemonConfig = RemonConfig()
    
    internal var firstInit:Bool = false
    
    
    // IBOutlet
    @IBOutlet public weak var remoteView:UIView?
    @IBOutlet public weak var localView:UIView?
    
    
    @objc public var volumeRatio:Double = 1.0 {
        didSet {
            if (self.volumeRatio > 1.0) {
                self.volumeRatio = 1.0
            } else if (self.volumeRatio < 0.0) {
                self.volumeRatio = 0.0
            }
            controller.setAudioVolume(ratio: self.volumeRatio)
        }
    }
    
    public var closeType:RemonCloseType {
        get { return controller.context.closeType }
    }
    
    public var latestError:RemonError? {
        get { return controller.latestError }
    }
    
    public var remonState:RemonState {
        get { return controller.context.state}
    }
    
    /// 갭처러 객체
    @objc public var localCapturer: RTCVideoCapturer? {
        get {
            return RemonCapturerManager.getInstance().videoCapturer
        }
    }
    
    
    /** 연결이 완료 된 후 로컬 비디오 캡쳐를 자동으로 시작 할 지 여부 */
    @objc public var autoCaptureStart:Bool {
        get { return remonConfig.autoCaptureStart }
        set(value) { remonConfig.autoCaptureStart = value }
    }
    
    /** debug mode.  default is false */
    @objc public var debugMode:Bool {
        get { return remonConfig.debugMode }
        set(value) { remonConfig.debugMode = value }
    }
    
    @objc public var userMeta:String {
        set(meta) { remonConfig.userMeta = meta }
        get { return remonConfig.userMeta }
    }
    
    
    /// 외부 캡처러 사용 여부 설정
    @objc public var useExternalCapturer:Bool {
        get { return remonConfig.useExternalCapturer }
        set(value) { remonConfig.useExternalCapturer = value }
    }
    
    /// ICE Server 목록
    @objc public var iceServers:[RTCIceServer] {
        get { return remonConfig.iceServers }
        set(value) { remonConfig.iceServers = value }
    }

    /// Selective Candidate
    @objc public var selectiveCandidate:RemonConfig.SelectiveCandidate {
        get { return remonConfig.selectiveCandidate }
        set(value) { remonConfig.selectiveCandidate = value }
    }
    
    
    // IBInspectable
    /** video codec H264 | VP8. default is H264 */
    @IBInspectable @objc public var videoCodec:String {
        get { return remonConfig.videoCodec }
        set(value) { remonConfig.videoCodec = value }
    }
    
    /// 오디오 전용 여부 선택
    @IBInspectable @objc public var onlyAudio:Bool {
        get { return !remonConfig.videoCall }
        set(value) { remonConfig.videoCall = (!value) }
    }
    
    /// 비디오 가로 크기
    @IBInspectable @objc public var videoWidth:Int {
        get { return remonConfig.videoWidth }
        set(value) { remonConfig.videoWidth = value }
    }
    
    /// 비디오 세로 크기
    @IBInspectable @objc public var videoHeight:Int{
        get { return remonConfig.videoHeight }
        set(value) { remonConfig.videoHeight = value }
    }
    
    /// 초당 프레임 수
    @IBInspectable @objc public var fps:Int{
        get { return remonConfig.videoFps }
        set(value) { remonConfig.videoFps = value }
    }
    
    /// 서비스 아이디
    @IBInspectable @objc public var serviceId:String{
        get { return remonConfig.serviceId }
        set(value) { remonConfig.serviceId = value }
    }
    
    /// 서비스키
    @IBInspectable @objc public var serviceKey:String {
        get { return remonConfig.key }
        set(value) { remonConfig.key = value }
    }
    
    /// 서비스 토큰
    @IBInspectable @objc public var serviceToken:String {
        get { return remonConfig.serviceToken }
        set(value) { remonConfig.serviceToken = value }
    }
    
    /// rest api 주소
    @IBInspectable @objc public var restUrl:String {
        get { return remonConfig.restUrl }
        set(value) { remonConfig.restUrl = value }
    }
    
    /// 웹소켓 주소
    @IBInspectable @objc public var wsUrl:String {
        get { return remonConfig.wsUrl }
        set(value) { remonConfig.wsUrl = value }
    }
    
    /// log 서버 주소
    @IBInspectable @objc public var logUrl:String {
        get { return remonConfig.logUrl }
        set(value) { remonConfig.logUrl = value }
    }
    
    /// 전면 카메라 시작
    @IBInspectable @objc public var frontCamera:Bool {
        set( isFront ) { remonConfig.frontCamera = isFront }
        get { return remonConfig.frontCamera }
    }
    
    /// 카메라 화면 미러모드 동작여부, 화면만 미러로 동작하며, 실제 데이터는 정상 전송
    @IBInspectable @objc public var mirrorMode:Bool {
        get { return remonConfig.mirrorMode }
        set( isMirror) { remonConfig.mirrorMode = isMirror }
    }
    
    /**
     최종 output 프레임 고정여부.
     true 인 경우 연결시의 방향으로 출력 사이즈가 고정됩니다.
     false 인 경우 앱이 지원하는 방향으로 회전이 이루어집니다.
     단, 앱이 하나의 방향만을 지원하는 경우 회전이 발생하지 않습니다.
     */
    @IBInspectable @objc public var fixedCameraRotation:Bool {
        get { return remonConfig.fixedCameraRotation }
        set(value) { remonConfig.fixedCameraRotation = value }
    }
    
    
    @objc public var useDeviceOrientation:Bool {
        get { return remonConfig.useDeviceOrientation }
        set(value) { remonConfig.useDeviceOrientation = value }
    }
    
    
    @IBInspectable @objc public var videoStartBitrate:String {
        get { return remonConfig.videoStartBitrate }
        set(value) { remonConfig.videoStartBitrate = value }
    }

    
    
    /// 시뮬레이터에서 사용할 동영상 파일명
    @IBInspectable @objc public var videoFilePathForSimulator:String? {
        get { return remonConfig.videoFilePathForSimulator }
        set(value) { remonConfig.videoFilePathForSimulator = value }
    }
    
    @objc public var statIntervalTime:Int {
        get { return remonConfig.statIntervalTime }
        set(value) { remonConfig.statIntervalTime = value }
    }
    
    
    
    @objc public var audioType:String {
        get { return remonConfig.audioType }
        set(value) { remonConfig.audioType = value }
    }
    
    @objc public var audioAutoGain:Bool {
        get { return remonConfig.audioAutoGain }
        set(value) { remonConfig.audioAutoGain = value}
    }
    
    
    #if REMON_AUDIO_PROCESSING
    /**
     현재 오디오 레벨 정보를 얻어옵니다.
     지원버전 : 2.7.10+
     방송송출, p2p 연결시는 로컬 입력레벨이고, 방송수신자, 컨퍼런스 참여자는 리모트의 출력레벨입니다.
     */
    @objc public var currentAudioLevel:Int {
        get { return controller.currentAudioLevel }
    }
    #endif
    
    
    
    // deprecated
    @available(*, deprecated, message: "use localCapturer" )
    public var localCameraCapturer:RTCCameraVideoCapturer?
    
    /// 외부 캡처러 사용시 프레임 데이터를 전달할 객체
    @available(*, deprecated, message: "use localCapturer" )
    public var localSampleCapturer:RemonSampleCapturer?
    
    // preview 요소 deprecated
    @available(*, deprecated, message: "use localView")
    public weak var localPreView:UIView?
    
    
    @available(*, deprecated, message: "use onStat instead")
    @objc public var showRemoteVideoStat = false
    
    @available(*, deprecated, message: "use onStat instead")
    @objc public var showLocalVideoStat = false
    
    
    @available(*, deprecated, message: "use latestError property instead")
    public func getLatestError() -> RemonError? {
        return controller.latestError
    }
}

/**
 클라이언트에서 호출하는 메쏘드들에 대한 인터페이스 확장 클래스
 */
extension RemonClient {
    @objc public func setConfig( config:RemonConfig ) {
        remonConfig.setConfig(other: config)
    }
    
    /**
     */
    @objc public func getCurrentRemonState() -> Int {
        return self.remonState.rawValue
    }
    
    /** 현재 상태를 문자열로 얻어옵니다.
     */
    @objc public func getCurruntStateString() -> String {
        let stateString = "UNKNOWN"

        switch self.remonState {
        case RemonState.CLOSE:
            return "CLOSE"
        case RemonState.CONNECT:
            return "CONNECT"
        case RemonState.COMPLETE:
            return "COMPLETE"
        case RemonState.CREATE:
            return "CREATE"
        case RemonState.INIT:
            return "INIT"
        default:
            break
        }
        
        
        return stateString
    }
    
    /**
     webrtc 연결 종료
     */
    @objc public func closeRemon() {
        self.closeRemon(type: .MINE)
    }
    
    @objc public func closeRemon(type: RemonCloseType ) {
        if controller.context.state != RemonState.CLOSE {
            controller.context.requestClose(type: type)
        }
    }
    
    
    /**
     대역폭 전환
     */
    public func switchSimulcastLayer(bandwidth:RemonBandwidth) {
        controller.switchSimulcastLayer(bandwidth: bandwidth)
    }
    
    @objc public func switchSimulcastLayer(bandwidth:objc_RemonBandwidth) {
        controller.switchSimulcastLayer(bandwidth: bandwidth)
    }
    
   
    
    /**
     원격지 사운드 켜거나 끄기
     */
    @objc public func setRemoteAudioEnabled(isEnabled:Bool = true) -> Void {
        controller.setRemoteAudioEnabled(isEnabled: isEnabled)
    }
    
    /**
     로컬 사운드 켜거나 끄기
     */
    @objc public func setLocalAudioEnabled(isEnabled:Bool = true ) -> Void {
        controller.setLocalAudioEnabled(isEnabled: isEnabled)
    }
    
    /**
        로컬 비디오 켜거나 끄기
     */
    @objc public func setLocalVideoEnabled(isEnabled:Bool = true ) -> Void {
        controller.setLocalVideoEnabled(isEnabled: isEnabled)
    }
    
    /**
        원격지 비디오 켜거나 끄기
     */
    @objc public func setRemoteVideoEnabled(isEnabled:Bool = true) -> Void {
        controller.setRemoteVideoEnabled(isEnabled: isEnabled)
        
        if controller.context.channelType == .viewer {
            controller.configureStream(video: isEnabled, audio: true)
        }
    }
    
    /**
     로컬 비디오(카메라) 시작
     로컬 비디오를 사용하는 모든 연결에 영향이 있으므로, 특정 연결된 세션의 비디오를 켜거나 끄는 경우
     setLocalVideoEnabled( isEnabled: true ) 메쏘드 사용.
     */
    @discardableResult
    @objc public func startLocalVideoCapture(completion:@escaping ()->Void) -> Bool {
        return self.controller.startLocalVideoCapture(completion: completion)
    }
    
    /**
     로컬 비디오(카메라) 중지
     */
    @discardableResult
    @objc public func stopLocalVideoCapture() -> Bool {
        return self.controller.stopLocalVideoCapture()
    }
    
    /**
     * 채널이 연결된 상태에서 상대편에게 메시지를 전달한다.
     */
    @objc public func sendMessage(message:String){
        controller.sendMessage(message: message)
    }
    
    /**
     카메라 전환
     현재 카메라의 미러모드를 전환하거나, 전후면 카메라를 전환한다
     -Parameters:
     +isMirror: 미러모드 적용 여부
     +isToggle: 카메라 전면,후면 전환 여부
     
     -Return:변경된 카메라가 전면이면 true, 후면이면 false
     */
    @discardableResult
    @objc public func switchCamera( isMirror:Bool = false, isToggle:Bool = true) -> Bool {
        return self.controller.switchCamera( isMirror:isMirror, isToggle:isToggle)
    }
    
    /**
     볼륨설정
     */
    @objc public func setVolume(volume:Float) -> Void {
        self.controller.setVolume( volume: volume)
    }
    
    /**
     채널 목록 요청
     */
    public func fetchChannel(
        type:RemonSearchType,
        roomName:String?,
        complete: @escaping (_ error:RemonError?, _ results:Array<RemonSearchResult>?)->Void) {
            RemonRestManager.fetchChannel(
                type: type,
                serviceID: self.serviceId,
                roomName: roomName,
                restUrl: remonConfig.restUrl ) { (results) in
                    DispatchQueue.main.async {
                        complete(nil, results)
                    }
                }
    }
    
    
    @objc public func startDump(withFileName: String, maxSizeInBytes:Int64) -> Void {
        self.controller.startDump(withFileName: withFileName, maxSizeInBytes: maxSizeInBytes)
    }
    
    @objc public func stopDump() -> Void {
        self.controller.stopDump()
    }
    
    @objc static public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, avPreset:REMON_AECUNPACK_PRESET, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonClientController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, avPreset: avPreset, progress: progress )
    }
    
    @objc static public func unpackAecDump (dumpName:String? = "audio.aecdump", resultFileName:String, progress: @escaping (Error?, REMON_AECUNPACK_STATE) -> Void) -> Void {
        RemonClientController.unpackAecDump(dumpName: dumpName, resultFileName: resultFileName, progress: progress)
    }
    
    
    @objc public func showLocalVideo() -> Void {
        self.controller.showLocalVideo(client: self)
    }
    
    public func switchBandWidth(bandwidth:RemonBandwidth) {
        controller.switchSimulcastLayer(bandwidth: bandwidth)
    }
    
    @objc public func switchBandWidth(bandwidth:objc_RemonBandwidth) {
        controller.switchSimulcastLayer(bandwidth: bandwidth)
    }
    

    
    @objc public func attachLocalVideoTo(view:UIView) {
        self.controller.viewManager?.detachLocalVideoRenderer()
        self.controller.viewManager?.attachLocalVideoRenderer(localView: view, delegate: controller)
        self.controller.viewManager?.mirroringLocalView(mirror: self.mirrorMode )
        self.localView = view
    }

    @objc public func attachRemoteVideoTo(view:UIView) {
        self.controller.viewManager?.detachRemoteVideoRenderer()
        self.controller.viewManager?.attachRemoteVideoRenderer(remoteView: view, delegate: controller)
        self.remoteView = view
    }
    
    @objc public func detachLocalVideo() {
        self.controller.viewManager?.detachLocalVideoRenderer()
    }
    
    @objc public func detachRemoteVideo() {
        self.controller.viewManager?.detachRemoteVideoRenderer()
    }
    
    // android 와 인터페이스 맞추기 위해 deprecated
    @available(*, deprecated, message: "Use setRemoteAudioEnabled( isEnabled: Bool )")
    @objc public func muteRemoteAudio(mute:Bool = true) -> Void {
        self.controller.setRemoteAudioEnabled(isEnabled: !mute)
    }
    
    // android 와 인터페이스 맞춤
    @available(*, deprecated, message: "Use setLocalAudioEnabled( isEnabled: Bool )")
    @objc public func muteLocalAudio(mute:Bool = true) -> Void {
        self.controller.setLocalAudioEnabled(isEnabled: !mute)
    }
    

    @available(*, deprecated, message: "Use setRemoteVideoEnabled( isEnabled: true)")
    @objc public func startRemoteVideoCapture() -> Void {
        self.controller.setRemoteVideoEnabled(isEnabled: true)
    }
    
    @available(*, deprecated, message: "Use setRemoteVideoEnabled( isEnabled: false)")
    @objc public func stopRemoteVideoCapture() -> Void {
        self.controller.setRemoteAudioEnabled(isEnabled: false)
    }
    
    
}



extension RemonClient: RemonControllerBlockSettable{
    //set oberserver block
    internal func onFetchChannels(block:@escaping RemonArrayBlock) {
        self.controller.observerBlock.fetchRemonChannelBlock = block
    }
    
    internal func onCreateInternal(block:@escaping RemonStringBlock) {
        self.controller.observerBlock.createRemonChannelBlock = block
    }
    
    internal func onConnectInternal(block:@escaping RemonVoidBlock) {
        self.controller.observerBlock.connectRemonChannelBlock = block
    }
    
    /** 초기화 콜백 */
    @objc public func onInit(block:@escaping RemonVoidBlock) {
        self.controller.observerBlock.initRemonBlock = block
    }
    
    /** Peer간 접속 완료 콜백. webrtc 접속이 완료된 이후에 호출 */
    @objc public func onComplete(block:@escaping RemonVoidBlock) {
        self.controller.observerBlock.completeRemonChannelBlock = block
    }
    
    /** 연결 종료 콜백 */
    @objc public func onClose(block:@escaping RemonCloseBlock) {
        self.controller.observerBlock.closeRemonChannelBlock = block
    }
    
    @objc public func onDisConnect(block:@escaping RemonStringBlock) {
        self.controller.observerBlock.disConnectRemonChannelBlock = block
    }
    
    /** 메시지 수신 콜백 */
    @objc public func onMessage(block:@escaping RemonStringBlock) {
        self.controller.observerBlock.messageRemonChannelBlock = block
    }
    
    /** 에러 콜백 */
    public func onError(block:@escaping RemonErrorBlock) {
        self.controller.observerBlock.errorRemonBlock = block
    }
    
    @objc public func onObjcError(block:@escaping ((_:NSError) -> Void)) {
        self.controller.observerBlock.objc_errorRemonBlock = block
    }
    
    @objc public func onStat(block:@escaping (_:RemonStatReport)->Void) {
        self.controller.observerBlock.remonStatBlock = block
    }
    
    @objc public func onReconnect(block: @escaping RemonVoidBlock) {
        self.controller.observerBlock.reconnectRemonChannelBlock = block
    }
    
    /** 원격측 비디오 사이즈 변경시 호출 */
    @objc public func onRemoteVideoSizeChanged(block: @escaping (_ remoteView:UIView?, _ videoSize:CGSize) -> Void) {
        self.controller.observerBlock.didChangeRemoteVideoSize = block
    }
    
    /** 로컬 비디오 사이즈 변경시 호출 */
    @objc public func onLocalVideoSizeChanged(block: @escaping (_ localView:UIView?, _ videoSize:CGSize) -> Void) {
        self.controller.observerBlock.didChangeLocalVideoSize = block
    }

    @objc public func onRoomEvent(block: @escaping (_ type:String, _ channel:String) -> Void) {
        self.controller.observerBlock.roomEventBlock = block
    }
    
    @available(*, deprecated, message: "use onStat")
    @objc public func onRemonStatReport(block:@escaping (_:RemonStatReport)->Void) {
        self.controller.observerBlock.remonStatBlock = block
    }
}





extension RemonClient {

    #if (!arch(arm64))
    @available(*, deprecated, message: "use remoteVideoView")
    public var remoteRTCEAGLVideoView:RTCEAGLVideoView?{
        get {
            return self.controller.viewManager?.remoteVideoView
        }
    }

    @available(*, deprecated, message: "use localVideoView")
    public var localRTCEAGLVideoView:RTCEAGLVideoView? {
        get {
            return self.controller.viewManager?.localVideoView
        }
    }
    
    public var remoteVideoView:RTCEAGLVideoView?{
        get {
            return self.controller.viewManager?.remoteVideoView
        }
    }
    
    public var localVideoView:RTCEAGLVideoView? {
        get {
            return self.controller.viewManager?.localVideoView
        }
    }
    
    #else
    @available(*, deprecated, message: "use remoteVideoView")
    public var remoteRTCEAGLVideoView:RTCMTLVideoView?{
        get {
            return self.controller.viewManager?.remoteVideoView
        }
    }
    
    @available(*, deprecated, message: "use localVideoView")
    public var localRTCEAGLVideoView:RTCMTLVideoView? {
        get {
            return self.controller.viewManager?.localVideoView
        }
    }
    

    public var remoteVideoView:RTCMTLVideoView?{
        get {
            return self.controller.viewManager?.remoteVideoView
        }
    }
    
    public var localVideoView:RTCMTLVideoView? {
        get {
            return self.controller.viewManager?.localVideoView
        }
    }
    #endif
    
    @available(*, deprecated, message: "use localVideoView")
    public var localRTCCameraPreviewView:RemonCameraPreviewView? {
        get {
            return nil; //self.controller.remonView?.localRTCCameraPreviewView
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
    @objc public static func setAudioSessionConfiguration(
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options:AVAudioSession.CategoryOptions ) {
        RemonClient.setAudioSessionConfiguration(category: category, mode: mode, options: options,delegate: nil)
    }
    
    
    @objc public static func setAudioSessionConfiguration(
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options:AVAudioSession.CategoryOptions,
        delegate:RTCAudioSessionDelegate?) {
        
        // webrtc 전역 오디오세션 카테고리 설정
        let ac = RTCAudioSessionConfiguration()
        ac.category = category.rawValue
        ac.mode = mode.rawValue
        ac.categoryOptions =  options
        ac.ioBufferDuration = 0.06
        
        RTCAudioSessionConfiguration.setWebRTC(ac)
        
        #if DEBUG
        print("[RemonClient.setAudioSessionConfiguration] category=\(ac.category)")
        print("[RemonClient.setAudioSessionConfiguration] mode=\(ac.mode)")
        print("[RemonClient.setAudioSessionConfiguration] options=\(ac.categoryOptions)")
        #endif
 
        let session = RTCAudioSession.sharedInstance()
        if delegate != nil {
            session.add(delegate!)
        }
        
        session.lockForConfiguration()
        do {
            try session.setConfiguration(ac)
        } catch let error as NSError {
            print("[RemonClient] setAudioSessionConfiguration: ** Error RTCAudioSessionConfiguration", error.localizedDescription)
        }
        session.unlockForConfiguration()
        //
    }
    
    /**
     여러 피어를 동시에 사용할 경우 특정 피어 종료시 오디오세션 정보가 초기화 됩니다.
     여러 피어를 사용하는 환경에서는 setAudioSessionConfiguration() 으로 기본적인 오디오 세션을 설정하고,
     각 피어의 연결과 해제시에 setAudioSessionWithCurrentCategory() 를 호출해주어야 기존 설정이 유지됩니다.
     */
    @objc public static func setAudioSessionWithCurrentCategory() {
        let ac = RTCAudioSessionConfiguration.webRTC()
        
        #if DEBUG
        print("[RemonClient.setAudioSessionWithCurrentCategory] category=\(ac.category)")
        print("[RemonClient.setAudioSessionWithCurrentCategory] mode=\(ac.mode)")
        print("[RemonClient.setAudioSessionWithCurrentCategory] options=\(ac.categoryOptions)")
        print("[RemonClient.setAudioSessionWithCurrentCategory] sampleRate=\(ac.sampleRate)")
        print("[RemonClient.setAudioSessionWithCurrentCategory] ioBufferDuration=\(ac.ioBufferDuration)")
        #endif
        
        let session = RTCAudioSession.sharedInstance()
        session.lockForConfiguration()
        try? session.setCategory(ac.category, with: ac.categoryOptions)
        session.unlockForConfiguration()
    }
    
}
