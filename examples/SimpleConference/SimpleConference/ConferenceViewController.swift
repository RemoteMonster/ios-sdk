//
//  ViewController.swift
//  SimpleConference
//
//  Created by Chance Kim on 2019/11/13.
//  Copyright © 2019 remote monster. All rights reserved.
//

import UIKit
import RemoteMonster

// 이 샘플은 iOS SDK 2.6.13 이상 버전이 필요합니다.
class ConferenceViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var buttonAudio: UIButton!
    
    @IBOutlet weak var roomIdField: UITextField!
    @IBOutlet var viewArray: [UIView]!
    
    @IBOutlet weak var messageBottomConstraint: NSLayoutConstraint!
    
    var roomId:String?
    var remonConference:RemonConference?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIApplication.shared.isIdleTimerDisabled = true
         NotificationCenter.default.addObserver(self, selector: #selector(ConferenceViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(ConferenceViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        RemonClient.setAudioSessionConfiguration(
                   category: AVAudioSession.Category.playAndRecord,
                   mode: AVAudioSession.Mode.videoChat,
                   options:[.defaultToSpeaker]);
        
        // 아래 설정은 music 모드로 목소리,주변음,디바이스에서 재생되는 사운드를 그대로 전달할 때 사용합니다.
        // 프로젝트 폴더의 RemonSettings.plist에 AudioType이 music으로 설정되어야 정상 동작합니다.
        /*
        RemonClient.setAudioSessionConfiguration(
            category: AVAudioSession.Category.playAndRecord,
            mode: AVAudioSession.Mode.default,
            options: [.mixWithOthers, .defaultToSpeaker]);
        */
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // close remon room
        self.remonConference?.leave()
        self.remonConference = nil
    }
    


    func initRemonConference() {
        // 객체생성
        self.remonConference = RemonConference()
        
        self.remonConference?.create{ participant in
            // init master channel
            
            // 현재 그룹통화는 베타 기간으로 아래의 서버 url을 사용해야 합니다.
            participant.restUrl = "https://conference.remotemonster.com"
            participant.wsUrl = "wss://conference.remotemonster.com/ws"
            
            // 일반적인 RemonClient 설정
            participant.serviceId = "SERVICEID1"
            participant.serviceKey = "1234567890"
            participant.videoWidth = 640
            participant.videoHeight = 480
            
            // 마스터유저의 localView 지정
            participant.localView = self.viewArray[0]
            
            // 시뮬레이터의 경우 카메라가 없으므로 대체 재생할 mov 파일을 지정해 줍니다.
            //participant.videoFilePathForSimulator = "samples.mov"
        }.then { channelName in
            // 마스터유저가 송출 채널에 접속하면 호출됩니다.
            print("[ConferenceViewController] master=\(channelName!)")
        }.close {
            // 마스터유저가 끊어진 경우 호출됩니다.
            // 그룹통화에서 끊어진 것이므로, 다른 유저와의 연결도 모두 끊어집니다.
        }.error { error in
            // 마스터유저의 채널에 오류가 있는 경우 호출됩니다.
            self.showAlert(title: "onError:\(error.localizedDescription)")
        }
    }
    
    func joinConference( roomName:String ) {
        
        // 그룹통화에 참여합니다.
        self.remonConference?
            .join(roomName: roomName)
            .on { [weak self] channelName, index, participant in
                // 다른 사용자가 접속한 경우 호출됩니다.
                // 그룹통화는 특정 인원의 slot이 존재하고, 참여한 사용자의 slot 번호가 index로 전달됩니다.
                print("[ConferenceViewController] ch=\(channelName),index=\(index)")
                
                // 다른 사용자와 연결할 정보를 설정합니다.
                
                // 다른 사용자의 화면을 표시할 remoteView설정
                participant.remoteView = self?.viewArray[index]
                
        }.then { channelName in
            print("[ConferenceViewController] onJoin")
            // 다른 사용자와 연결되면 호출됩니다.
        }.close {
            print("[ConferenceViewController] onClose")
            // 다른 사용자와의 연결이 끊어지면 호출됩니다.
        }.error { err in
            print("[ConferenceViewController] onError. err=\(err.localizedDescription)")
            // 다른 사용자와위 연결에  오류 발생시 호출됩니다.
            self.showAlert(title: "onError:\(err.localizedDescription)")
        }
    }

    
    // 그룹통화 연결 버튼 이벤트
    @IBAction func touchConnectRoom(_ sender: Any) {
        self.hideKeyboard()
        
        // 객체 초기화
        initRemonConference()
        
        // 방 이름
        self.roomId = self.roomIdField.text
        
        // 방에 접속
        if let name = self.roomId {
            self.joinConference(roomName: name)
            
        } else {
            self.showToast(message: "Please enter room name")
        }
        
    }
    
    // 그룹통화 떠나기
    @IBAction func touchLeaveRoom(_ sender: Any) {
        self.hideKeyboard()

        self.remonConference?.leave()
        self.remonConference = nil
    }
    
    
    // 오디오 활성화/비활성화
    @IBAction func touchAudio(_ sender: Any) {
        buttonAudio.isSelected = !buttonAudio.isSelected
        
        let participant = self.remonConference?.getClient(index: 0)
        participant?.setLocalAudioEnabled(isEnabled: buttonAudio.isSelected)
    }
    
    @IBAction func onClickedSend(_ sender: Any) {
    }
    
    
    // MARK: - 아래는 기존 RemonCall 샘플 코드
    // ConferenceCall 의 경우 현재 메시지 송수신을 지원하지 않습니다.
    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
    
    func updateKeyboardConstraint( notification: NSNotification ) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = self.view.convert(keyboardFrame, from: self.view.window)
        let rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16
        let animationCurve = UIView.AnimationOptions(rawValue: UInt( rawAnimationCurve ))
        
        messageBottomConstraint.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.beginFromCurrentState.rawValue|animationCurve.rawValue),
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    
    @objc func keyboardWillShow( notification: NSNotification ) {
        updateKeyboardConstraint(notification: notification)
    }
    
    @objc func keyboardWillHide( notification: NSNotification ) {
        updateKeyboardConstraint(notification: notification)
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showAlert(title:String) -> Void {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (handle) in }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {})
    }
}

