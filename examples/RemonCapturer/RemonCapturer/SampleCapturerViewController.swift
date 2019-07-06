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
 ## 외부 라이브러리를 사용한 프레임 커스터마이징 예제
 캡처, 이미지 프로세싱 등의 작업을 직접 처리하기 원하는 경우 RemonSampleCapturer를 통해 커스터마이징된 프레임을 전송 가능
 GPUImage 라이브러리 사용하는 예로 CVPixelBuffer 처리 필요
 라이브러리, Apple core video, core image 관련 내용은 해당 레퍼런스 참조
 */
class SampleCapturerViewController: UIViewController {
    @IBOutlet var remonCall: RemonCall!
    
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var enBtn: UIButton!
    @IBOutlet weak var localView: UIView!
    

    // 카메라 캡처 라이브러리
    var videoCamera:GPUImageVideoCamera?
    private var cmTime:CMTime?

    
    
    // CIImage의 렌더링을 위한 객체
    var ciContext:CIContext?
    var sampleImage:CIImage?
    var pointRatio:CGPoint = CGPoint()
    
    
    
    @IBAction func enterChannel(_ sender: UIButton) {
        if let chid = self.chField.text {
            self.remonCall.connect(chid)
        }
        self.view.endEditing(true)
    }
    
    @IBAction func exitChannel(_ sender: UIButton) {
        self.remonCall.closeRemon()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if let localView = self.remonCall.localView {
            var location:CGPoint = touch.location(in: localView)
            location.y = localView.frame.height - location.y
            
            pointRatio.x = max( 0, min( 1, location.x / localView.frame.width ))
            pointRatio.y = max( 0, min( 1, location.y / localView.frame.height))
        }
    }
    
    func initRemonCallbacks() {
        self.remonCall.useExternalCapturer = true
        
        // 서버와의 세션 연결
        remonCall.onInit {
            print("[Client.onInit]")
            
        }
        
        
        // 피어 연결
        remonCall.onComplete { [weak self] () in
            print("[Client.onComplete]")
            
            self?.startCapture()
        }
        
        
        // 피어 연결 종료, 서버세션 종료
        remonCall.onClose {  [weak self](_) in
            print("[Client.onClose]")
            self?.videoCamera?.stopCapture()
        }
        
        
        // 에러 발생
        remonCall.onError {  (error) in
            print("[Client.onError] error=\(error.localizedDescription)")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ciContext = CIContext(options: [CIContextOption.outputPremultiplied: true, CIContextOption.useSoftwareRenderer: false])
        
        let fileURL = Bundle.main.url(forResource: "remon_identity", withExtension: "png")
        if let fileURL = fileURL {
            self.sampleImage = CIImage(contentsOf: fileURL)
        }
        
        initRemonCallbacks()

    }
    

    
    

    /**
     startCapture
     
     */
    private func startCapture() -> Void {

        // 비디오 카메라 초기화
        videoCamera = GPUImageVideoCamera.init(
            sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue,
            cameraPosition: AVCaptureDevice.Position.front)
        
        guard let videoCamera = self.videoCamera
        else {
            // 비디오 카메라 생성 실패
            return
        }
        
        // 카메라 출력 설정
        // RemonSampleCapturer는 입력되는 소스의 orientation을 그대로 전송합니다.
        // 다양한 카메라 방향을 지원하려면 해당 라이브러리를 통해 직접 처리해야 합니다.
        // 본 예제에서는 세로모드(portrait)의 출력 데이터를 사용합니다.
        videoCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        videoCamera.horizontallyMirrorFrontFacingCamera = false
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.frameRate = 24

        
        
        // 카메라 필터 예
        let filter:GPUImageToonFilter = GPUImageToonFilter()
        filter.quantizationLevels = 5.0
        filter.threshold = 10.0
        
        // 카메라에 필터 추가
        videoCamera.addTarget(filter)

        
        // raw data output
        // 보통 GPUImageRawDataOutput 클래스를 상속받아 newFrameReady, newFrameAvailableBlock을 사용
        guard let op = GPUImageRawDataOutput.init(imageSize: CGSize.init(width: 720, height: 1280), resultsInBGRAFormat: true)  else {
            return
        }
        filter.addTarget(op)
        
        // 캡처 시작
        videoCamera.startCapture()

        // 라이브러리의 프레임 출력 : GPUImageOutput, 타임스탬프
        filter.frameProcessingCompletionBlock = { [weak self](imageOutput, time) in
            self?.cmTime = time
            
            
        }
        
        
        // CVPixelBuffer 를 생성해 복사뒤 SDK로 전달
        op.newFrameAvailableBlock = { [weak self]() in
            op.lockFramebufferForReading()
            let pointer = op.rawBytesForImage
            let bytesPerRow = Int(op.bytesPerRowInOutput())
            let width = Int(op.maximumOutputSize().width)
            let height = Int(op.maximumOutputSize().height)
            let data = CFDataCreate(kCFAllocatorDefault, op.rawBytesForImage, bytesPerRow*height)
            op.unlockFramebufferAfterReading()
            
            let unmanagedData = Unmanaged<CFData>.passRetained(data!)
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreateWithBytes( kCFAllocatorDefault,
                                                      width,
                                                      height,
                                                      kCVPixelFormatType_32BGRA,
                                                      pointer!,
                                                      bytesPerRow,
                                                      { (releaseContext, baseAddress) in
                                                        let contextData = Unmanaged<CFData>.fromOpaque(releaseContext!)
                                                        contextData.release() },
                                                      unmanagedData.toOpaque(),
                                                      nil,
                                                      &pixelBuffer)

            if (status != kCVReturnSuccess) {
                return
            }

            
            // image draw
            // cvpixelbuffer 를 통해 원하는 처리 추가
            // Apple Core Image 참조
            if let buffer = pixelBuffer {
                let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
                
                CVPixelBufferLockBaseAddress( buffer, [] )
                
                let frameImage = CIImage(cvPixelBuffer: buffer, options: [CIImageOption.colorSpace:colorSpace])
                
                if let filterComposite: CIFilter = CIFilter( name:"CISourceOverCompositing"), let image = self?.sampleImage {
                    
                    let x = frameImage.extent.width * ( self?.pointRatio.x ?? 0 )
                    let y = frameImage.extent.height * ( self?.pointRatio.y ?? 0 )
                    filterComposite.setDefaults()
                    filterComposite.setValue(
                        image.transformed(by: CGAffineTransform(translationX: x, y: y)),
                    forKey: kCIInputImageKey)
                
                    filterComposite.setValue(frameImage, forKey: kCIInputBackgroundImageKey)
                
                
                    if let output = filterComposite.outputImage {
                        self?.ciContext?.render(output, to: buffer, bounds: output.extent, colorSpace: colorSpace )
                    }
                }
                CVPixelBufferUnlockBaseAddress( buffer, [] )
                
            }
            
            // RemonSampleCapturer로 CVPixelBuffer 전달
            if let pixelBuffer = pixelBuffer {
                self?.remonCall.localSampleCapturer?.willOutputPixelBuffer(pixelBuffer, time: (self?.cmTime!)! )
            }
        }
    }
}
    

