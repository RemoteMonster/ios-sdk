//
//  SimpleCallViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster
import AVFoundation

class SimpleCallViewController: UIViewController {
    
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var chLabel: UILabel!
    
   
    // IB Object로 등록한 RemonCall 객체
    @IBOutlet weak var remonCall: RemonCall!
    
    
    // config를 사용해 접속 정보와 서비스 설정을 할 수 있습니다.
    // 현재 샘플에서는 ConifgViewController에서 config를 전달합니다.
    // config객체는 connect() 호출시 복사되어 전달됩니다.
    var customConfig:RemonConfig? = nil
    
    
    var frontCamera = false
    var muted = false
    
    @IBAction func volumeRatioP(_ sender: Any) {
        self.remonCall.volumeRatio = self.remonCall.volumeRatio + 0.1
    }
    
    @IBAction func volumeRatioM(_ sender: Any) {
        self.remonCall.volumeRatio = self.remonCall.volumeRatio - 0.1
    }
    
    @IBAction func ewf(_ sender: Any) {
        self.remonCall.showLocalVideoStat = true
        self.remonCall.showRemoteVideoStat = true
    }
    
    @IBAction func awedawef(_ sender: Any) {
        self.remonCall.muteLocalAudio(mute: !self.muted)
        self.muted = !self.muted
    }
    

    // 1:1 통화를 위한 채널에 접속합니다.
    @IBAction func connectChannel(_ sender: Any) {
        self.view.endEditing(true)
        
        // 입력된 채널명(채널ID)
        let channelID = self.chField.text
        
        if channelID != nil && channelID!.count > 0 {
            
            // config는 별도 설정한 뒤에 전달해도 되며, nil 인 경우 remonCall 내부 프로퍼티 값을 사용하게 됩니다.
            // 내부 프로퍼티는 IB에서 설정할 수 있습니다.
            remonCall.connect(channelID!, customConfig)
            self.chLabel.text = channelID
        } else {
            
            // 랜덤번호를 채널명으로 사용하는 예
            let randChannelID:String! = String(arc4random_uniform(9999))
            remonCall.connect(randChannelID, customConfig)
            self.chLabel.text = randChannelID
        }
    }
    
    
    // 카메라 위치를 동적으로 변경합니다.
    @IBAction func switchCamera(_ sender: Any) {
        // 미러모드
        var mirror:Bool = true

        // 현재 전면 카메라이고, 변경시 카메라가 후면 카메라인 경우에는 미러모드 끄기
        if self.frontCamera {
            mirror = false
        }

        // supported v2.6.4 or higher
        self.frontCamera = self.remonCall.switchCamera( isMirror: mirror, isToggle: true)
    }
    
    // 카메라는 변경하지 않고, 현재 카메라 화면만 미러모드로 변경합니다.
    @IBAction func switchMirrorMode(_ sender: Any) {
        let mirror:Bool = !self.remonCall.mirrorMode
        
        // 카메라 전환
        // supported v2.6.4 or higher
        self.frontCamera = self.remonCall.switchCamera( isMirror: mirror, isToggle: false)
    }
    
    
    
    // SDK에서 전달하는 이벤트를 처리하기 위한 콜백 함수를 정의합니다.
    func initRemonCallbacks() {
        
        // 초기화에 사용될 값은 IB에서 설정하거나 이곳에서 직접 설정합니다.
        // 이 값들은 초기화에 사용되어지며, 초기화 이후에는 동적으로 변경되지 않으므로 값을 참조하지 마시기 바랍니다.
        if let config = self.customConfig {
            config.frontCamera = true

        } else {
            remonCall.frontCamera = true
        }

        
        self.frontCamera = remonCall.frontCamera
        
        
        // 각 이벤트 콜백을 등록합니다.
        // 서버와의 세션 연결
        remonCall.onInit { [weak self] in
            print("[Client.onInit]")
            self?.boxView.isHidden = true
        }
        
        
        // 피어 연결
        remonCall.onComplete { [weak self] () in
            print("[Client.onComplete]")
            self?.chLabel.text = self?.remonCall.channelID
        }
        
        
        // 피어 연결 종료, 서버세션 종료
        remonCall.onClose { [weak self] (_) in
            print("[Client.onClose]")
            
            self?.remonCall?.stopDump()
        }
        
        
        // 에러 발생
        remonCall.onError { [weak self] (error) in
            print("[Client.onError] error=\(error.localizedDescription)")
            self?.chLabel.text = error.localizedDescription
            
            
            
            // error 는 RemonError 형식이므로
            // 특정 오류에 대해 예외처리를 세분화 하려면 아래처럼 에러를 구분해 처리합니다.
            switch error {
            case .ConnectChannelFailed(_):
                break
                
            default:
                break
                
            }
        }
        
        // 재시도
        remonCall.onRetry { [weak self] (completed) in
            print("[Client.onRetry]")
            print(self.debugDescription)
        }
        
        
        // 로컬 비디오의 사이즈 변경
        remonCall.onLocalVideoSizeChanged { [weak self] (localView, size) in
            print("[Client.onLocalVideoSizeChanged]", size)
            print(self.debugDescription)
        }
        
        
        // 연결된 피어의 비디오 사이즈 변경
        remonCall.onRemoteVideoSizeChanged { [weak self] (view, size) in
            print("[Client.onRemoteVideoSizeChanged] size=\(size)")
            
            // 뷰의 constraint 변경
            self?.remonCall.remoteView?.constraints.forEach({ (item) in
                if item.identifier == "RemoteViewAspectRatio" {
                    item.setMultiplier(multiplier: size.width / size.height)
                }
            })
            
        }
        
        // 로컬 비디오 사이즈 변경
       remonCall.onLocalVideoSizeChanged { [weak self] (view, size) in
            print("[Client.onRemoteVideoSizeChanged] size=\(size)")
            
            // 뷰의 constraint 변경
            self?.remonCall?.localView?.constraints.forEach({ (item) in
                if item.identifier == "LocalViewAspectRatio" {
                    item.setMultiplier(multiplier: size.width / size.height)
                }
            })

        }
        
        
//        //음성 저장을 위한 덤프 루틴입니다.
//        let apapap = aecunpack()
//        apapap.run(dumpName: "dump.dump", resultFileName: "result.m4a") { (err, state) in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//
//            }
//        }
    }
    
    override func viewDidLoad() {
        print("[Client.viewDidLoad]")
        super.viewDidLoad()
        
        // sdk 오디오세션 설정
        // AVAudioSession.Mode.voiceChat : 수화기 사용
        // AVAudioSession.Mode.videoChat : 스피커 사용
        RemonClient.setAudioSessionConfiguration(
            category: AVAudioSession.Category.playAndRecord,
            mode: AVAudioSession.Mode.videoChat,
            options: [] );
        
        
        // SDK 콜백 등록
        initRemonCallbacks()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        // 뷰가 pop 되는 경우 sdk를 종료합니다
        self.remonCall?.closeRemon()
        self.customConfig = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
