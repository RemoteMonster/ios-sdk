//
//  ViewController.swift
//  externalSampler
//
//  Created by lhs on 14/01/2019.
//  Copyright © 2019 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster
import GPUImage

class EXSViewController: UIViewController, GPUImageVideoCameraDelegate {
    @IBOutlet var remonCall: RemonCall!
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var enBtn: UIButton!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var rotateButton: UIButton!
    
    var videoCamera:GPUImageVideoCamera?
    private var cmTime:CMTime?
    private var NOOP:Bool = false
    private var mySampleBuffer:CVPixelBuffer?
    
    @IBAction func enterChannel(_ sender: UIButton) {
        if let chid = self.chField.text {
            self.remonCall.connect(chid)
        }
        self.view.endEditing(true)
    }
    
    
    @IBAction func exitChannel(_ sender: UIButton) {
        self.remonCall.closeRemon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.remonCall.useExternalCapturer = true
        
        self.remonCall.onComplete {
            self.startCapture()
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
    
    private func startCapture() -> Void {
        let gpuImageSource: AVCaptureDevice.Position! = AVCaptureDevice.Position.front
        self.videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: gpuImageSource)
        
        let filter:GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
        
        
        filter.blurRadiusInPixels = 5.0
        if let videoCamera = self.videoCamera {
            videoCamera.delegate = self
            videoCamera.addTarget(filter)
            videoCamera.frameRate = 24
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
                            
                            /**
                             이 예제에서는 통신 연결이 완료 된후 startCapture()이 호출 됩니다.
                             만약 연결이 완료 되지 않은 상태에서 startCapture()가 호출 되지 않았다면 아래 분기는 실행 되지 않습니다.
                             이후 연결이 완료되어 localExternalCaptureDelegator가 획득 된다면 아래 분기는 실행 됩니다.
                             **/
                            if let rtcCaptureDelegate = self.remonCall.localExternalCaptureDelegator {
                                rtcCaptureDelegate.didCaptureFrame(pixelBuffer: pixelBuffer, timeStamp: cmTime, videoRetation: ._0)
                            }
                        }
                    }
                }
                
            }
        }
    }
                
}
