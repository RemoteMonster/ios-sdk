//
//  ViewController.swift
//  SimpleConference
//
//  Created by Chance Kim on 2019/11/13.
//  Copyright © 2019 remote monster. All rights reserved.
//

import UIKit
import RemoteMonster

// 이 샘플은 iOS SDK 2.7.3 이상 버전이 필요합니다.
class ConferenceViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var buttonAudio: UIButton!
    
    @IBOutlet weak var roomIdField: UITextField!
    @IBOutlet var viewArray: [UIView]!
    var availableViews:[Bool]?
    var error:RemonError?
    
    @IBOutlet weak var messageBottomConstraint: NSLayoutConstraint!
    
    var roomId:String?
    var remonConference:RemonConference?
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    func joinConference( roomName:String ) {
        // 공통적으로 사용될 기본 설정
        let config = RemonConfig()
        config.serviceId = "SERVICEID1"
        config.key = "1234567890"
        config.videoWidth = 640
        config.videoHeight = 480
        
        // 시뮬레이터의 경우 카메라가 없으므로 대체 재생할 mov 파일을 지정해 줍니다.
        //config.videoFilePathForSimulator = "samples.mov"
    
        self.remonConference = RemonConference()
        self.remonConference?.create( roomName: roomName, config: config) { (participant) in
            // 마스터 유저(송출자,나자신) 초기화
            participant.localView = self.viewArray[0]
            
            // 뷰 설정용
            availableViews?[0] = true
            
        }.on( eventName: "onRoomCreated") {
            participant in
            // 마스터 유저가 접속된 이후에 호출(실제 송출 시작)
            participant.setLocalAudioEnabled(isEnabled: self.buttonAudio.isSelected)
            // TODO: 실제 유저 정보는 각 서비스에서 관리하므로, 서비스에서 채널과 실제 유저 매핑 작업 진행
            
            // tag 객체에 holder 형태로 객체를 지정해 사용할 수 있습니다.
            // 예제에서는 단순히 view의 index를 저장합니다.
            participant.tag = 0
            self.showToast(message: "\(participant.id)")
            
        }.on(eventName: "onUserJoined" ) {
            [weak self] participant in
            // 다른 사용자가 입장한 경우 초기화를 위해 호출됨
            // 초기화와 유저 매핑 등을 위해 호출되는 이벤트로 실제 peer 연결전에 호출됩니다.
            // TODO: 실제 유저 매핑 : participant.id 값으로 연결된 실제 유저를 얻습니다.
            
            
            // 뷰 설정
            if let index = self?.getAvailableView() {
                participant.localView = nil
                participant.remoteView = self?.viewArray[index]
                participant.tag = index
            }
            
            // 접속한 상대방의 RemonClient 콜백이 필요한 경우 아래와 같이 등록
            // 룸 콜백으로 참여,연결,퇴장 이벤트가 전달되므로 특별한 경우가 아니면 등록할 필요는 없습니다.
            participant.on(event: "onComplete" ) {
                _ in
                // onUserStreamConnected 와 동일
            }.on(event: "onClose") {
                _ in
                // onUserLeaved 호출된 이후 호출됨
            }.on(event: "onError") {
                _ in
            }
            
            self?.showToast(message: "\(participant.id) has joined")
            
        }.on(eventName: "onUserConnected") {
            participant in
            // v2.7.3 추가
            // 실제 스트림세션 연결이 이루어지면 호출됩니다.
            
            
        }.on(eventName: "onUserLeaved") {
            [weak self] participant in
            // 다른 사용자가 퇴장한 경우
            // participant.id 와 participant.tag 를 참조해 어떤 사용자가 퇴장했는지 확인후 퇴장 처리를 합니다.
            if let index = participant.tag as? Int {
                self?.availableViews?[index] = false
            }
            
            if participant.getLatestError() != nil {
                // 에러로 끊어진 경우
                // 재시도 처리 등은 각 서비스 상황에 맞게 구현
            }
            
            self?.showToast(message: "\(participant.id) has leaved")
        }.close {
            // 마스터 유저가 종료된 경우 호출됩니다.
            // 송출이 중단되면 그룹통화에서 끊어진 것이므로, 다른 유저와의 연결도 모두 끊어집니다.
            if( self.error != nil ) {
                // 에러로 종료됨
            } else {
                // 종료됨
            }
            
        }.error { err in
            // 마스터유저(송출 채널)의 오류 발생시 호출됩니다.
            // 오류로 연결이 종료되면 error -> close 순으로 호출됩니다.
            self.error = err
        }
    }

    
    // 그룹통화 연결 버튼 이벤트
    @IBAction func touchConnectRoom(_ sender: Any) {
        self.hideKeyboard()
        
        self.availableViews = [Bool](repeating: false, count: self.viewArray.count)
        
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
            
        self.availableViews?.removeAll()
        self.availableViews = nil
        
        self.remonConference?.leave()
        self.remonConference = nil
    }
    
    
    // 오디오 활성화/비활성화
    @IBAction func touchAudio(_ sender: Any) {
        buttonAudio.isSelected = !buttonAudio.isSelected
        
        if let participant = self.remonConference?.me {
            participant.setLocalAudioEnabled(isEnabled: buttonAudio.isSelected)
        }
    }
    
    @IBAction func onClickedSend(_ sender: Any) {
    }
    

    func getAvailableView() ->Int {
        if let views = self.availableViews {
            for i in 0 ... views.count {
                if views[i] == false {
                    self.availableViews?[i] = true
                    return i
                }
            }
        }
        
        return 0
    }
    
    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 50, y: self.view.frame.size.height-100, width: self.view.frame.size.width - 100, height: 70))
        toastLabel.numberOfLines = 2
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
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

