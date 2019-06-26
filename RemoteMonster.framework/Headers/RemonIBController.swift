//
//  RemonIBController.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit



/***/
@objc(RemonIBController)
@IBDesignable
public class RemonIBController:NSObject, RemonControllBlockSettable {

    var controller: RemonController? = nil
    
    // public
    // deprecated : 뷰 설정 작업을 직접 진행하는 경우에 사용
    public weak var legacyDelegate: RemonDelegate?
    
    /** 연결이 완료 된 후 로컬 비디오 캡쳐를 자동으로 시작 할 지 여부 */
    public var autoCaptureStart:Bool = true
    
    /**video codec H264 | VP8. default is H264 */
    public var videoCodec:String = "H264"
    
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
    
    
    @objc public var useExternalCapturer:Bool = false
    @objc public var channelID:String?
    public var localCameraCapturer:RTCCameraVideoCapturer? {
        get {
            return controller?.localCameraCapturer
        }
    }
    
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
    


    
    /***/
    internal var channelType:RemonChannelType = .p2p
    internal var autoReJoin_:Bool = false
    internal var firstInit:Bool = false
    internal var sendonly:Bool = false
    internal var tryReConnecting:Bool = false
    
    // IBInspectable
    @IBInspectable public var onlyAudio:Bool = false
    @IBInspectable public var videoWidth:Int = 640
    @IBInspectable public var videoHeight:Int = 480
    @IBInspectable public var fps:Int = 24
    @IBInspectable public var serviceId:String?
    @IBInspectable public var serviceKey:String?
    @IBInspectable public var wsUrl:String = "wss://signal.remotemonster.com/ws"
    @IBInspectable public var restUrl:String = "https://signal.remotemonster.com/rest/init"
    @IBInspectable public var frontCamera:Bool = true
    @IBInspectable public var mirrorMode:Bool = false
    @IBInspectable public var fixedCameraRotation:Bool = false
    
    
    // @IBInspectable public var autoReJoin:Bool
    // @IBInspectable public var audioType:RemonAudioMode

    
    // IBOutlet
    @IBOutlet dynamic public weak var remoteView:UIView?
    @IBOutlet dynamic public weak var localView:UIView?
    @IBOutlet dynamic public weak var localPreView:UIView?
    
    
}



//
// client interface function
//
extension RemonIBController {
    @objc func getCurrentRemonState() -> Int {
        if let status = self.currentRemonState {
            return status.rawValue
        } else {
            return RemonState.CLOSE.rawValue
        }
    }
    
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
    
    
    @objc public func closeRemon() {
        controller?.closeRemon()
    }
    
    
    
    public func switchBandWidth(bandwidth:RemonBandwidth) {
        controller?.switchBandWidth(bandwidth: bandwidth)
    }
    
    @objc public func objc_switchBandWidth(bandwidth:objc_RemonBandwidth) {
        controller?.objc_switchBandWidth(bandwidth: bandwidth)
    }
    
    @objc func setAudioToSpeaker(){
        controller?.setAudioToSpeaker()
    }
    
    
    @objc public func muteRemoteAudio(mute:Bool = true) -> Void {
        controller?.muteRemoteAudio(mute: mute)
    }
    
    @objc public func muteLocalAudio(mute:Bool = true) -> Void {
        controller?.muteLocalAudio(mute: mute)
    }
    
    @objc public func stopLocalVideoCapture() -> Bool {
        return controller?.stopLocalVideoCapture() ?? false
    }
    
    @objc public func startLocalVideoCapture() -> Bool {
        return controller?.startLocalVideoCapture() ?? false
    }
    
    @objc public func stopRemoteVideoCapture() -> Void {
        controller?.stopRemoteVideoCapture()
    }
    
    @objc public func switchCamera(mirror:Bool = false) -> Bool {
        return controller?.switchCamera(client: self, mirror:mirror) ?? false
    }
    
    @objc public func startRemoteVideoCapture() -> Void {
        controller?.startRemoteVideoCapture()
    }
    
    @objc public func setVolume(volume:Float) -> Void {
        controller?.setVolume(client: self, volume: volume)
    }
    
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
    public func onError(block:@escaping RemonErrorBlock) { controller?.observerBlock.errorRemonBlock = block}
    @objc public func onInit(block:@escaping RemonVoidBlock) { controller?.observerBlock.initRemonBlock = block}
    @objc public func onComplete(block:@escaping RemonVoidBlock) { controller?.observerBlock.completeRemonChannelBlock = block}
    @objc public func onClose(block:@escaping RemonCloseBlock) {controller?.observerBlock.closeRemonChannelBlock = block}
    @objc public func onDisConnect(block:@escaping RemonStringBlock) { controller?.observerBlock.disConnectRemonChannelBlock = block}
    @objc public func onMessage(block:@escaping RemonStringBlock) { controller?.observerBlock.messageRemonChannelBlock = block}
    @objc public func onObjcError(block:@escaping ((_:NSError) -> Void)) { controller?.observerBlock.objc_errorRemonBlock = block}
    @objc public func onRetry(block:@escaping ((_:Bool) -> Void)) { controller?.observerBlock.tryReConnect = block}
    @objc public func onRemonStatReport(block:@escaping (_:RemonStatReport)->Void) {controller?.observerBlock.remonStatBlock = block}
    @objc public func onRemoteVideoSizeChanged(block: @escaping (_ remoteView:UIView?, _ videoSize:CGSize) -> Void) {
        controller?.observerBlock.didChangeRemoteVideoSize = block
    }
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
