//
//  VCasterViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleVideoCastViewController:UIViewController {

    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet weak var captureView: UIImageView!
    
    // IB Object로 등록한 RemonCast 객체
    @IBOutlet weak var remonCast: RemonCast!
    
    
    // config를 사용해 접속 정보와 서비스 설정을 할 수 있습니다.
    // 샘플에서는 ConifgViewController에서 config를 전달합니다.
    // config객체는 connect() 호출시 복사되어 전달됩니다.
    var customConfig:RemonConfig?
    
    
    // 전면 카메라에만 미러보기를 적용하기 위해 별도 변수를 사용
    var isFrontCamera:Bool = false
    var isMirrorMode:Bool = false
    
    
    // 방송 송출을 위해 서비스에 연결합니다.
    @IBAction func createBroadcast(_ sender: Any) {
        
        self.remonCast.create(customConfig)
    }
    
    // 서비스 종료
    @IBAction func closeBroadcast(_ sender: Any) {
        self.remonCast.closeRemon()
    }
    
    
    // 카메라 위치를 동적으로 변경합니다.
    @IBAction func switchCamera(_ sender: Any) {

        // 미러모드 : 초기 설정된 값으로 지정
        isMirrorMode = self.remonCast.mirrorMode
        
        
        // 현재 전면 카메라이면 바뀌는 카메라는 후면카메라이므로, 미러모드 끄기
        if self.isFrontCamera {
            isMirrorMode = false
        }


        // 카메라 전환
        self.isFrontCamera = self.remonCast.switchCamera( isMirror: isMirrorMode)
        print("[Client.onSwitchCamera] switchCamera=\(isMirrorMode)")
    }
    
    
    @IBAction func captureView(_ sender: Any) {
        guard self.remonCast.localVideoView != nil else {
            return
        }
        let image = self.image(with: self.view)
        self.captureView.image = image
    }
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    // SDK에서 전달하는 이벤트를 처리하기 위한 콜백 함수를 정의합니다.
    func initRemonCallbacks() {
        self.isFrontCamera = remonCast.frontCamera
        
        self.remonCast.onInit { [weak self] in
            self?.createBtn.isEnabled = false
        }
        
        self.remonCast.onCreate { [weak self] (chid) in
            self?.closeBtn.isEnabled = true
            self?.chLabel.text = chid
        }
        
        self.remonCast.onClose { [weak self](_) in
            self?.createBtn.isEnabled = true
            self?.closeBtn.isEnabled = false
        }
        
        
        // 에러 발생
        self.remonCast.onError { [weak self] (error) in
            print("[Client.onError] error=\(error.localizedDescription)")
            self?.chLabel.text = error.localizedDescription
            
            
            
            // error 는 RemonError 형식이므로
            // 특정 오류에 대해 예외처리를 세분화 하려면 아래처럼 에러를 구분해 처리합니다.
            // error 는 RemonError 형식이므로
            // 특정 오류에 대해 예외처리를 세분화 하려면 아래처럼 에러를 구분해 처리합니다.
            switch error {
            case .RestInitError(let code, let message):
                print("[Client.onError] code=\(code),message=\(message)")
                break
                
            case .InitError( let code, let message):
                print("[Client.onError] code=\(code),message=\(message)")
                break
                
                
            default:
                break
                
            }
        }
        
        
        // 로컬 비디오 사이즈 변경
        self.remonCast.onLocalVideoSizeChanged { [weak self] (view, size) in
            print("[Client.onRemoteVideoSizeChanged] size=\(size)")
            
            // 뷰의 constraint 변경
            self?.remonCast?.localView?.constraints.forEach({ (item) in
                if item.identifier == "LocalViewAspectRatio" {
                    item.setMultiplier(multiplier: size.width / size.height)
                }
            })
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sdk 오디오세션 설정 : supported v2.6.10 or higher
        // 세부 내용은 애플 AVAudioSession 레퍼런스 참조
        // iOS의 경우 RemonSettings.plist 에 추가 설정 필요
        // AVAudioSession.Mode.voiceChat : 수화기 사용
        // AVAudioSession.Mode.videoChat : 스피커 사용
        RemonClient.setAudioSessionConfiguration(
            category: AVAudioSession.Category.playAndRecord,
            mode: AVAudioSession.Mode.videoChat,
            options: [] );
        
        initRemonCallbacks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 뷰가 pop 되는 경우 sdk를 종료합니다
        self.remonCast?.closeRemon()
        self.customConfig = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}



