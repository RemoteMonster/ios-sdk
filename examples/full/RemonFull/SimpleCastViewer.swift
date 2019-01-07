//
//  VViwerViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 30..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleCastViewer: UIViewController {
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet var remonCast: RemonCast!
    
    var toChID:String?
    var customConfig:RemonConfig?
    var socketErr = false

    
    @IBAction func showStat(_ sender: Any) {
        self.remonCast.showRemoteVideoStat = true
    }
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            
        })
        self.remonCast.closeRemon()
        self.chLabel.text = "closing..."
    }
    
    @IBAction func test(_ sender: Any) {
//        self.remonCast.reconnectRoom()
        
    }
    
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
        
        if let chID = self.toChID {
            //config is nilable
            self.remonCast.join(chId: chID, customConfig)
        }
        
        self.remonCast.onJoin { (chid) in
            DispatchQueue.main.async {
                self.closeBtn.isEnabled = true
                self.chLabel.text = self.toChID
            }
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
                }
                else {
                    AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSessionCategoryPlayback)
                }
                
                try AVAudioSession.sharedInstance().setActive(true, with: [])
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            } catch {
                print(error)
            }
        }
        
        self.remonCast.onInit {
            self.socketErr = false
            DispatchQueue.main.async {
                self.chLabel.text = "init..."
            }
        }
        
        self.remonCast.onRetry { (com) in
            print(com)
        }
        
        
        self.remonCast.onRemonStatReport { (report) in
            let remoteFrameRate = report.remoteFrameRate
            let localFrameRate = report.localFrameRate
            
            print("remonStat.remoteFrameRate A®" , remoteFrameRate)
        }
        
        self.remonCast.onError { (error) in
            print("ERROR" , error.localizedDescription)
            if (error.localizedDescription.contains("error 3")){
                self.remonCast.closeRemon()
                self.socketErr = true
            }
        }
        self.remonCast.onClose { (type) in
            if self.socketErr {
                self.socketErr = false
                if let chid = self.toChID {
                    self.remonCast.join(chId: chid)
                }
            }
        }
        
        self.remonCast.onRemoteVideoSizeChanged { (view, size) in
            print("Debug onRemoteVideoSizeChanged", size)
            print("Debug remonCast\(self.remonCast.remoteView.hashValue) and view\(view.hashValue) is same")
            
            let videoHeight = size.height
            let videoWidth = size.width
            let videoRatio:CGFloat = videoWidth / videoHeight
            
            guard let myView = view else { return }
            
            let myViewWidth:CGFloat = myView.frame.size.width
            let myViewHeight:CGFloat = myView.frame.size.height
            let myViewRatio:CGFloat = myViewWidth / myViewHeight
            
            if videoRatio < 1.0 {
                if myViewRatio < 1.0 {
                    let computedWidth:CGFloat = myViewHeight * videoRatio
                    print("Debug computedWidth", computedWidth)
                    DispatchQueue.main.async {
                        myView.frame = CGRect(x: 0.0, y: 0.0, width: computedWidth, height: myViewHeight)
                        myView.center = self.view.center
                    }
                } else {
                    //                    NOOP
                }
            } else {
                if myViewRatio < 1.0 {
                    let computedWidth:CGFloat = myViewHeight * videoRatio
                    print("Debug computedWidth", computedWidth)
                    DispatchQueue.main.async {
                        myView.frame = CGRect(x: -430.0, y: 170.0, width: computedWidth, height: myViewHeight)
//                        myView.center = self.view.center
                    }
                }
            }
        }
        
//        if let view = self.remonCast.remoteView {
//            let degrees:Double = 20
//            view.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi / Double(180)));
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.remonCast.closeRemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
