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

class MeshCallViewController: UIViewController, UITextFieldDelegate, GPUImageVideoCameraDelegate {
    
    @IBOutlet var remonCall_0: RemonCall!
    @IBOutlet var remonCall_1: RemonCall!
    @IBOutlet var remonCall_2: RemonCall!
    @IBOutlet var remonCall_3: RemonCall!
    @IBOutlet var remonCall_4: RemonCall!
    @IBOutlet var remonCall_5: RemonCall!
    
    @IBOutlet weak var chField_0: UITextField!
    @IBOutlet weak var chField_1: UITextField!
    @IBOutlet weak var chField_2: UITextField!
    @IBOutlet weak var chField_3: UITextField!
    @IBOutlet weak var chField_4: UITextField!
    @IBOutlet weak var chField_5: UITextField!
    
    
    @IBOutlet weak var chLabel_0: UILabel!
    @IBOutlet weak var chLabel_1: UILabel!
    @IBOutlet weak var chLabel_2: UILabel!
    @IBOutlet weak var chLabel_3: UILabel!
    @IBOutlet weak var chLabel_4: UILabel!
    @IBOutlet weak var chLabel_5: UILabel!
    
    @IBOutlet weak var chButton_0: UIButton!
    @IBOutlet weak var chButton_1: UIButton!
    @IBOutlet weak var chButton_2: UIButton!
    @IBOutlet weak var chButton_3: UIButton!
    @IBOutlet weak var chButton_4: UIButton!
    @IBOutlet weak var chButton_5: UIButton!
    
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var buttonStartCapture: UIButton!
    
    @IBOutlet var remons: [RemonCall]!
    
    var videoCamera:GPUImageVideoCamera?
    private var cmTime:CMTime?
    private var NOOP:Bool = false
    private var mySampleBuffer:CVPixelBuffer?
    
    @IBAction func touchStartCapture(_ sender: UIControl) {
        self.startCapture()
    }
    
    @IBAction func endCh_0(_ sender: UIControl) {
        self.chButton_0.isEnabled = true
        self.disconnectChannel(label: self.chLabel_0, remon: remonCall_0)
    }
    
    @IBAction func endCh_1(_ sender: UIControl) {
        self.chButton_1.isEnabled = true
        self.disconnectChannel(label: self.chLabel_1, remon: remonCall_1)
    }
    
    @IBAction func endCh_2(_ sender: UIControl) {
        self.chButton_2.isEnabled = true
        self.disconnectChannel(label: self.chLabel_2, remon: remonCall_2)
    }
    
    @IBAction func endCh_3(_ sender: UIControl) {
        self.chButton_3.isEnabled = true
        self.disconnectChannel(label: self.chLabel_3, remon: remonCall_3)
    }
    
    @IBAction func endCh_4(_ sender: UIControl) {
        self.chButton_4.isEnabled = true
        self.disconnectChannel(label: self.chLabel_4, remon: remonCall_4)
    }
    
    @IBAction func endCh_5(_ sender: UIControl) {
        self.chButton_5.isEnabled = true
        self.disconnectChannel(label: self.chLabel_5, remon: remonCall_5)
    }
    
    
    @IBAction func goCh_0(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_0.text {
            self.connectChannel(chid: chid, label:self.chLabel_0, remon: remonCall_0)
        }
    }
    
    @IBAction func goCh_1(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_1.text {
            self.connectChannel(chid: chid, label:self.chLabel_1, remon: remonCall_1)
        }
    }
    
    @IBAction func goCh_2(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_2.text {
            self.connectChannel(chid: chid, label:self.chLabel_2, remon: remonCall_2)
        }
    }
    
    @IBAction func goCh_3(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_3.text {
            self.connectChannel(chid: chid, label:self.chLabel_3, remon: remonCall_3)
        }
    }
    
    @IBAction func goCh_4(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_4.text {
            self.connectChannel(chid: chid, label:self.chLabel_4, remon: remonCall_4)
        }
    }
    
    @IBAction func goCh_5(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_5.text {
            self.connectChannel(chid: chid, label:self.chLabel_5, remon: remonCall_5)
        }
    }
    
    func connectChannel(chid:String, label:UILabel, remon:RemonCall) -> Void {
        remon.connect(chid)
        
        self.hideKeyboard()
        
        remon.onConnect { (chid) in
            DispatchQueue.main.async {
                label.text = chid
            }
            if let chid = chid {
                print("mesh connect", chid)
            } else {
                print("mesh connect", "dmd?")
            }
        }
        
        remon.onComplete {
            print("mesh complete")
        }
        
        remon.onClose { (type) in
            print("mesh close", type)
            
            DispatchQueue.main.async {
                label.text = ""
            }
        }
    }
    
    func disconnectChannel(label:UILabel, remon:RemonCall) -> Void {
        remon.closeRemon()
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
            
            if let op = GPUImageRawDataOutput.init(imageSize: CGSize.init(width: 480, height: 640), resultsInBGRAFormat: true) {
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
                            self.remons.forEach { (mon) in
                                if let rtcCaptureDelegate = mon.localExternalCaptureDelegator {
                                    rtcCaptureDelegate.didCaptureFrame(pixelBuffer: pixelBuffer, timeStamp: cmTime, videoRetation: ._0)
                                }
                            }
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
        
        self.remons.forEach { (mon) in
            mon.videoCodec = "H264"
            mon.serviceId = "hyungeun.jo@smoothy.co"
            mon.serviceKey = "fd4d4ff5952ede14a8ecc453ad2f629bb33ff1e9380674f5"
            mon.fps = 1
            // 기본 챕처러를 사용한다고 선언할 경우 n개의 로컬 캡터러가 생성 되어짐.
            // 한개의 외부 캡쳐러를 사용하고, 한개의 캡쳐 결과를 각 연결에 전달 하는 방법으로 개발할 필요가 있음.
            // 외부 캡쳐러에 대한 가이드는 예제 'exrenalSampler'를 참조.
              mon.useExternalCapturer = true
            
            mon.onComplete {
                DispatchQueue.main.async {
                    self.buttonStartCapture.isEnabled = true
                }
            }
        }
    }

    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    @IBAction func aa(_ sender: Any) {
        self.hideKeyboard()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}

