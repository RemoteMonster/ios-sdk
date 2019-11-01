//
//  ViewController.swift
//  SimpleDualCall
//
//  Created by Chance Kim on 2019/10/24.
//  Copyright © 2019 remote monster. All rights reserved.
//

import UIKit
import RemoteMonster


// 가장 단순한 형태의 P2P 다중 통화에 대한 샘플입니다.
// 나를 제외한 2명과 통화하는 경우 사용자마다 2개의 채널을 생성해 총 3개의 채널을 사용합니다.
// 각 채널명은 중복되지 않은 명칭이어야 합니다. (테스트계정 사용시 다른 유저와 채널명이 중복될 수 있습니다.)
// 실제 서비스환경에서는 서비스를 위한 별도 DB를 사용하게 되므로, 해당 DB의 사용자 데이터를 사용해
// 중복되지 않는 채널명을 생성해 사용합니다.
class SimpleViewController: UIViewController {

    // 채널을 구분하기 위해 임의로 지정한 값입니다.
    enum ChannelIndex : Int{
        case FIRST
        case SECOND
        case PREVIEW
    }
    
    var currentSelectedChannel = ChannelIndex.FIRST
    
    
    // 스토리보드에 object로 등록된 객체들입니다.
    // 1:1 통화는 RemonCall 을 사용합니다.
    // 다중 통화를 위해서는 연결할 인원만큼 RemonCall 객체를 추가합니다.
    @IBOutlet weak var remonCall1: RemonCall!
    @IBOutlet weak var remonCall2: RemonCall!
    @IBOutlet weak var remonCallPreview: RemonCall!
    
    
    // UI 요소
    @IBOutlet weak var editChannel1: UITextField!
    @IBOutlet weak var editChannel2: UITextField!
    @IBOutlet weak var btnChannel1: UIButton!
    @IBOutlet weak var btnChannel2: UIButton!
    
    @IBOutlet weak var editMessage: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var btnRemote1: UIButton!
    @IBOutlet weak var btnRemote2: UIButton!
    
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView1: UIView!
    @IBOutlet weak var remoteView2: UIView!
    @IBOutlet weak var localView1: UIView!
    @IBOutlet weak var localView2: UIView!
    
    @IBOutlet weak var messageBottomConstraint: NSLayoutConstraint!
    
    // 연결 여부 저장을 위한 맵
    var connectionMap:[ChannelIndex:Bool] = [ChannelIndex.FIRST:false, ChannelIndex.SECOND:false]
    var currentSelectedIndex:ChannelIndex = ChannelIndex.FIRST

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // 화면 꺼짐 방지
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(SimpleViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SimpleViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        btnRemote1.isHidden = true
        btnRemote2.isHidden = true
        
        
        // 객체별 값 초기화
        initRemonCall()
        
        // 객체별 콜백 설정
        initRemonCallbacks(index:.FIRST)
        initRemonCallbacks(index:.SECOND)
        
        // sdk 2.6.12 이후 기존의 카메라 프리뷰는 deprecated 되었습니다.
        // 피어 연결전에 프리뷰를 표시하려면 showLocalVideo() 메쏘드를 호출해 localView를
        // 먼저 렌더링 하도록 지정할 수 있습니다.
        // showLocalVideo() 메쏘드는 init 시에 설정한 localView 하위에 렌더링뷰를 추가하고,
        // 로컬 캡처 장치로부터 전달되는 데이터를 보여주게 됩니다.
        // 각 피어에 영향을 받지 않는 프리뷰를 제공하고자 하는 경우 본 샘플처럼 프리뷰 용도의
        // RemonClient(RemonCall, RemonCast)를 사용해야 합니다.
        remonCallPreview.showLocalVideo()
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 뷰가 pop 되는 경우 sdk를 종료합니다
        self.remonCall1?.closeRemon()
        self.remonCall2?.closeRemon()
        self.remonCallPreview.closeRemon()
        
        self.remonCallPreview = nil
        self.remonCall1 = nil
        self.remonCall2 = nil
    }
    

    // 객체의 프로퍼티를 설정합니다.
    
    func initRemonCall() {
        
        // 프리뷰
        // 프리뷰를 사용할 경우 해당 객체 설정
        remonCallPreview.serviceId = "SERVICEID1"
        remonCallPreview.serviceKey = "1234567890"
        remonCallPreview.videoCodec = "VP8"
        remonCallPreview.videoWidth = 640
        remonCallPreview.videoHeight = 480
        remonCallPreview.fps = 24
        remonCallPreview.frontCamera = true
        remonCallPreview.localView = localView
        
        
        // 시뮬레이터용으로 사용하는 영상은 프로젝트에 제외되어 있으니 원하시는 파일을 추가해 사용하시기 바랍니다.
        remonCallPreview.videoFilePathForSimulator = "sample_movie.mov"
        
        
        
        // 채널1
        // 설정은 스토리보드상에서 직접 지정하거나 아래와 같이 수정합니다.
        // 특정 뷰가 필요하지 않은 경우에는 입력하지 않습니다.
        remonCall1.serviceId = "SERVICEID1"
        remonCall1.serviceKey = "1234567890"
        remonCall1.localView = localView1
        remonCall1.remoteView = remoteView1
        remonCall1.videoFilePathForSimulator = "sample_movie.mov"
        
        
        // 채널2
        // 필요한 연결 갯수에 따라 설정을 진행해야 합니다.
        remonCall2.serviceId = "SERVICEID1"
        remonCall2.serviceKey = "1234567890"
        remonCall2.localView = localView2
        remonCall2.remoteView = remoteView2
        remonCall1.videoFilePathForSimulator = "sample_movie.mov"
        
    }
    
    // 각 피어 연결에 대한 이벤트 콜백을 정의합니다.
    func initRemonCallbacks( index :ChannelIndex ) {
        var connectButton:UIButton?
        var selectButton:UIButton?
        var remonCall:RemonCall?
        
        switch index {
        case .FIRST:
            remonCall = remonCall1
            connectButton = self.btnChannel1
            selectButton = self.btnRemote1
            break
            
        case .SECOND:
            remonCall = remonCall2
            connectButton = self.btnChannel2
            selectButton = self.btnRemote2
            break
            
        case .PREVIEW:
            return
        }
        
        // 채널1번
        remonCall?.onInit {
        }
        
        remonCall?.onComplete { [weak self, connectButton, index] in
            connectButton?.titleLabel?.text = "끊기"
            selectButton?.isHidden = false
            self?.connectionMap[index] = true
        }
        
        remonCall?.onClose { [weak self, connectButton, index] closeType in
            connectButton?.titleLabel?.text = "연결"
            selectButton?.isHidden = true
            self?.connectionMap[index] = false
        }
        
        remonCall?.onError { error in
            print("error=\(error.localizedDescription)")
        }
        
        remonCall?.onMessage { [weak self] message in
            guard let message = message else {return}
            self?.showToast(message: "[\(index)] \(message)")
        }
        
    }
    
    // MARK: - Button
    
    // 채널1번 연결/종료 버튼
     @IBAction func onClickedButton1(_ sender: Any) {
         self.view.endEditing(true)
         
         if self.connectionMap[ChannelIndex.FIRST] ?? false {
             remonCall1.closeRemon()
             
         } else {
             let channelID = self.editChannel1.text
             if channelID != nil && channelID!.count > 0 {
                 remonCall1.connect(channelID!)
             } else {
                 showToast(message: "채널명을 입력하세요.")
             }
         }
     }
     
     
     // 채널2번 연결/종료 버튼
     @IBAction func onClickedButton2(_ sender: Any) {
         self.view.endEditing(true)

         if self.connectionMap[ChannelIndex.SECOND] ?? false {
             remonCall2.closeRemon()
         } else {
             let channelID = self.editChannel2.text
             if channelID != nil && channelID!.count > 0 {
                 remonCall2.connect(channelID!)
             } else {
                 showToast(message: "채널명을 입력하세요.")
             }
         }
     }
     
     
    @IBAction func onClickedRemote1(_ sender: Any) {
        if currentSelectedIndex != ChannelIndex.FIRST {
            btnRemote1.isSelected = !btnRemote1.isSelected
            btnRemote2.isSelected = !btnRemote1.isSelected
            currentSelectedIndex = ChannelIndex.FIRST
        }
    }
    
    @IBAction func onClickedRemote2(_ sender: Any) {
        if currentSelectedIndex != ChannelIndex.SECOND {
            btnRemote2.isSelected = !btnRemote2.isSelected
            btnRemote1.isSelected = !btnRemote2.isSelected
            currentSelectedIndex = ChannelIndex.SECOND
        }
    }
    @IBAction func onClickedSend(_ sender: Any) {
        self.view.endEditing(true)
        
        let message = self.editMessage.text
        if message != nil && message?.count == 0 {
            showToast(message: "메시지를 입력하세요.")
            return
        }
        
        var remonCall:RemonCall? = nil
        
        switch self.currentSelectedIndex {
        case .FIRST:
            remonCall = remonCall1
            break
            
        case .SECOND:
            remonCall = remonCall2
            break
            
        case .PREVIEW:
            return
        }
        
        remonCall?.sendMessage(message: message ?? "")
        
     }
    
    
    // MARK: - Keyboard
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
}

