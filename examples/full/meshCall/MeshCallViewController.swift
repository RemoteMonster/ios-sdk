//
//  ViewController.swift
//  meshCall
//
//  Created by lhs on 14/01/2019.
//  Copyright © 2019 Remon. All rights reserved.
//

import UIKit
import RemoteMonster
import GPUImage
import Conferance

class MeshCallViewController: UIViewController, UITextFieldDelegate, GPUImageVideoCameraDelegate, RemonConferanceServiceDelegate {
    
    @IBOutlet weak var chLabel_0: UILabel!
    @IBOutlet weak var chLabel_1: UILabel!
    @IBOutlet weak var chLabel_2: UILabel!
    @IBOutlet weak var chLabel_3: UILabel!
    @IBOutlet weak var chLabel_4: UILabel!
    @IBOutlet weak var chLabel_5: UILabel!

    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var buttonStartCapture: UIButton!
    
    @IBOutlet weak var roomIdField: UITextField!
    @IBOutlet var remoteViews: [UIView]!
    
    
    var roomId:String?
    
    var videoCamera:GPUImageVideoCamera?
    private var cmTime:CMTime?
    private var NOOP:Bool = false
    private var mySampleBuffer:CVPixelBuffer?
    
    var viewMap:[String:UIView] = [:]
    
    
    let remonConferance:RemonConferance = RemonConferance(serviceId: "hyungeun.jo@smoothy.co", serviceKey: "fd4d4ff5952ede14a8ecc453ad2f629bb33ff1e9380674f5")
    
    @IBAction func touchStartCapture(_ sender: UIControl) {
        self.startCapture()
    }
    
    @IBAction func touchConnectRoom(_ sender: Any) {
        
        self.remonConferance.configure { (error) in
            
        }
        
        self.hideKeyboard()
        if let roomId = self.roomIdField.text {
            if roomId.count != 0 {
                self.roomId = roomId
                let mId = String.makeUID(length: 13)
                self.remonConferance.roomUsers(roomId: roomId) { (roomUsers) in
                    if  roomUsers != nil{
                        var dummyMap:[String:UIView] = [String:UIView]()
                        var i:Int = 0
                        for userId in roomUsers! {
                            dummyMap[userId] = self.remoteViews[i]
                            i = i + 1
                        }
                        self.viewMap = dummyMap
                        self.remonConferance.connect(myUserId: mId, roomId: roomId, initialFriendViews:dummyMap, delegate: self)
                    } else {
                        self.remonConferance.connect(myUserId: mId, roomId: roomId, initialFriendViews:nil, delegate: self)
                    }
                }
            } else {
                
            }
        }
    }
    
    @IBAction func touchLeaveRoom(_ sender: Any) {
        self.hideKeyboard()
        self.remonConferance.disconnect()
    }
    
    func showAltert(title:String) -> Void {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (handle) in }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {})
    }
    
    private func startCapture() -> Void {
        let gpuImageSource: AVCaptureDevice.Position! = AVCaptureDevice.Position.front
        self.videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: gpuImageSource)
        
        let filter:GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
        
        filter.blurRadiusInPixels = 5.0
        if let videoCamera = self.videoCamera {
            videoCamera.delegate = self
            videoCamera.addTarget(filter)
            videoCamera.frameRate = 10
            videoCamera.outputImageOrientation = .portrait
            /**
             ExternalCapturer를 사용 할 경우 Remon이 제공 하는 preview를 사용 할 수 없게 됩니다.
             이 예제에서는 GPUImageView를 이용 하여 자신의 영상을 구현 하고 있습니다.
             **/
            DispatchQueue.main.async {
                let viewFrame = CGRect(origin: CGPoint.zero, size: self.localView.frame.size)
                let filteredVideoView:GPUImageView = GPUImageView.init(frame: viewFrame)
                self.localView.addSubview(filteredVideoView)
                filter.addTarget(filteredVideoView)
            }
            
            if let op = GPUImageRawDataOutput.init(imageSize: CGSize.init(width: 240, height: 320), resultsInBGRAFormat: true) {
                filter.addTarget(op)
                videoCamera.startCapture()
                
                op.newFrameAvailableBlock = { () in
                    if self.NOOP { return }
                    
                    let width = Int(op.maximumOutputSize().width)
                    let height = Int(op.maximumOutputSize().height)
                    
                    let pointer = op.rawBytesForImage
                    let data = CFDataCreate(nil, op.rawBytesForImage, width*height*4)
                    let unmanagedData = Unmanaged<CFData>.passRetained(data!)
                    
                    var pixelBuffer: CVPixelBuffer?
                    let status = CVPixelBufferCreateWithBytes(nil,
                                                              width,
                                                              height,
                                                              kCVPixelFormatType_32BGRA,
                                                              pointer!,
                                                              width*4,
                                                              { releaseContext, baseAddress in
                                                                let contextData = Unmanaged<CFData>.fromOpaque(releaseContext!)
                                                                contextData.release()},
                                                              unmanagedData.toOpaque(),
                                                              nil,
                                                              &pixelBuffer)
                    
                    if (status != kCVReturnSuccess) {
                        return;
                    }
                    
                    if let pixelBuffer = pixelBuffer {
                        if let cmTime = self.cmTime {
                            var _ = self.remonConferance.didCaptureFrame(pixelBuffer: pixelBuffer, timeStamp: cmTime, videoRetation: ._0)
                        }
                    }
                }
                
            }
        }
    }
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        self.cmTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
            !CMSampleBufferDataIsReady(sampleBuffer)) {
            self.NOOP = true
        } else {
            self.NOOP = false
            self.mySampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.remons.forEach { (mon) in
//            mon.videoCodec = "VP8"
//            mon.serviceId = "h.sik3768@gmail.com"
//            mon.serviceKey = "dkdlrhsotkfadldi"
//            mon.fps = 15
//            mon.videoWidth = 240
//            mon.videoHeight = 320
//            // 기본 챕처러를 사용한다고 선언할 경우 n개의 로컬 캡터러가 생성 되어짐.
//            // 한개의 외부 캡쳐러를 사용하고, 한개의 캡쳐 결과를 각 연결에 전달 하는 방법으로 개발할 필요가 있음.
//            // 외부 캡쳐러에 대한 가이드는 예제 'exrenalSampler'를 참조.
//            mon.useExternalCapturer = true
//
//            mon.onComplete {
//                DispatchQueue.main.async {
//                    self.buttonStartCapture.isEnabled = true
//                }
//            }
//        }
    }

    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
    
    //    MARK: RemonConferanceServiceDelegate implementation
    func didConnect(to roomId: String) {
        
    }
    
    func didFailToConnect(to roomId: String, with error: Error) {
        
    }
    
    func didDisconnect(from roomId: String, with error: Error?) {
        
    }
    
    func userDidConnect(userId: String) {
        if self.viewMap[userId] == nil {
            var targetView:UIView? = nil
            for view in remoteViews {
                var used = false
                self.viewMap.forEach { (key, v) in
                    if view.hash == v.hash {
                        used = true
                    }
                }
                if !used {
                    targetView = view
                    break
                }
            }
            
            if let targetView = targetView {
                self.viewMap[userId] = targetView
                self.remonConferance.setFriendVideo(userId: userId, in: targetView)
            }
        }
        
    }
    
    func userDidDisconnect(userId: String) {
        self.viewMap.removeValue(forKey: userId)
    }
    
    func userChangedVideoStatus(userId: String, enabled: Bool) {
        
    }
    
    func userChangedAudioStatus(userId: String, enabled: Bool) {
        
    }
}

