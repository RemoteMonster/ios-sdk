//
//  VViwerViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 30..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleCastViewerViewController: UIViewController {
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet var remonCast: RemonCast!
    
    
    
    // config를 사용해 접속 정보와 서비스 설정을 할 수 있습니다.
    // 샘플에서는 ConifgViewController에서 config를 전달합니다.
    // config객체는 connect() 호출시 복사되어 전달됩니다.
    var customConfig:RemonConfig?
    
    
    var toChID:String?
    var socketErr = false
    
    
    
    // 종료버튼 액션
    @IBAction func closeRemonManager(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            
        })
        self.remonCast.closeRemon()
        self.chLabel.text = "closing..."
    }
    
    
    // 테스트버튼 액션
    @IBAction func test(_ sender: Any) {

    }
    
    
    // 카메라전환 액션
    @IBAction func swichStream(_ sender: UIControl) {
        let tag = sender.tag
        var bandwidth:RemonBandwidth = .HIGH
        if tag == 0 {
            bandwidth = .HIGH
        } else if tag == 1 {
            bandwidth = .MEDIUM
        } else if tag == 2 {
            bandwidth = .LOW
        }
        
        self.remonCast.switchBandWidth(bandwidth: bandwidth)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemonClient.setAudioSessionConfiguration(
            category: AVAudioSession.Category.playback,
            mode: AVAudioSession.Mode.default,
            options: []);
        
        
        // SDK 콜백 등록
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
    
    
    func initRemonCallbacks() {
        self.remonCast.userMeta = "SimpleCastViewer"
        
        if let chID = self.toChID {
            //config is nilable
            self.remonCast.join(chId: chID, customConfig)
        }
        
        // 각 이벤트 콜백을 등록합니다.
        // 이벤트 콜백 등록시 [weak self] 사용해 self에 대한 강한참조를 제거해 주셔야합니다.
        self.remonCast.onJoin { [weak self] (chid) in
            self?.closeBtn.isEnabled = true
            self?.chLabel.text = self?.toChID
        }
        
        self.remonCast.onInit { [weak self] in
            self?.socketErr = false
            self?.chLabel.text = "init..."
        }
    
        
        
        self.remonCast.onStat { [weak self](report) in
           print(self?.debugDescription ?? "")
            
            _ = report.remoteFrameRate
            _ = report.localFrameRate
            
            //            print("remonStat.remoteFrameRate A®" , remoteFrameRate)
        }
        
        self.remonCast.onError { [weak self](error) in
            print("ERROR" , error.localizedDescription)
            if (error.localizedDescription.contains("error 3")){
                self?.remonCast.closeRemon()
                self?.socketErr = true
            }
        }
        self.remonCast.onClose { [weak self](type) in
            if self?.socketErr ?? false {
                self?.socketErr = false
                if let chid = self?.toChID {
                    self?.remonCast.join(chId: chid)
                }
            }
        }
        
        
        // 연결된 피어의 비디오 사이즈 변경
        self.remonCast.onRemoteVideoSizeChanged { [weak self] (view, size) in
            print("[Client.onRemoteVideoSizeChanged] size=\(size)")
            
            // 뷰의 constraint 변경
            self?.remonCast.remoteView?.constraints.forEach({ (item) in
                if item.identifier == "RemoteViewAspectRatio" {
                    item.setMultiplier(multiplier: size.width / size.height)
                }
            })
            
        }
        
    }
}
