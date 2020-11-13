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


/**
 이 예제는 업데이트되지 않습니다.
 외부 캡처러를 이용한 샘플 프로젝트는 /examples/RemonCapturer 를 참조하시기바랍니다.
 */
class EXSViewController: UIViewController, GPUImageVideoCameraDelegate {
    @IBOutlet var remonCall: RemonCall!
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var enBtn: UIButton!
    
    var videoCamera:GPUImageVideoCamera?
    private var cmTime:CMTime?
    
    @IBAction func enterChannel(_ sender: UIButton) {
        if let chid = self.chField.text {
            self.remonCall.connect(chid)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        외부 샘플러를 이용하겠다고 선언 합니다.
        self.remonCall.useExternalCapturer = true
        
        self.remonCall.onComplete {
            self.startCapture()
        }
    }
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        self.cmTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    }
    
    private func startCapture() -> Void {
        let gpuImageSource: AVCaptureDevice.Position! = AVCaptureDevice.Position.front
        self.videoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: gpuImageSource)
        
        let filter:GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
        filter.blurRadiusInPixels = 10.0
        if let videoCamera = self.videoCamera {
            videoCamera.delegate = self
            videoCamera.addTarget(filter)
            videoCamera.frameRate = 24
            
            if let op = GPUImageRawDataOutput.init(imageSize: CGSize.init(width: 480, height: 640), resultsInBGRAFormat: true) {
                filter.addTarget(op)
                videoCamera.startCapture()
                
                op.newFrameAvailableBlock = { () in
                    
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
                                                                contextData.release()
                    },
                                                              unmanagedData.toOpaque(),
                                                              nil,
                                                              &pixelBuffer)
                    
                    if (status != kCVReturnSuccess) {
                        return;
                    }
                    
                    if let pixelBuffer = pixelBuffer {
                        if let cmTime = self.cmTime {
                            self.remonCall.localSampleCapturer?.willOutputPixelBuffer(pixelBuffer, time: cmTime )
                        }
                    }
                }
            }
        }
    }
    
    
}

