//
//  SimpleCallViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleCallViewController: UIViewController {
    
    @IBOutlet var remonCall: RemonCall!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var chLabel: UILabel!
    
    var customConfig:RemonConfig?
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
    
    @IBAction func touchConnectButton(_ sender: Any) {
        self.view.endEditing(true)
        let chid = self.chField.text
        if chid != nil && chid!.count > 0 {
            //config is nilable
            remonCall.connect(chid!, customConfig)
            self.chLabel.text = chid
        } else {
            let rand:String! = String(arc4random_uniform(9999))
            //config is nilable
            remonCall.connect(rand, customConfig)
            self.chLabel.text = rand
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let apapap = aecunpack()
//        apapap.run(dumpName: "dump.dump", resultFileName: "result.m4a") { (err, state) in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//                
//            }
//        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
            try AVAudioSession.sharedInstance().setActive(true, with: [])
        } catch {
            print(error)
        }
        
        remonCall.useFrontCamera = false
        remonCall.onInit {
            DispatchQueue.main.async {
                self.boxView.isHidden = true
            }
        }
        
        remonCall.onComplete { () in
            DispatchQueue.main.async {
                self.chLabel.text = self.remonCall.channelID
            }
        }
        
        remonCall.onRemoteVideoSizeChanged { (remoteView, size) in
            print("aaaaa", size)
            let newFrame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            remoteView?.frame = newFrame
        }
        
        remonCall.onLocalVideoSizeChanged { (localView, size) in
            print("aaaaa", size, "bbb")
        }
        
        remonCall.onClose { (_) in
            DispatchQueue.main.async {
//                self.chLabel.text = "Close Remon-   "
            }
        }
        
        remonCall.onConnect { (ss) in
            
        }
        
        remonCall.onError { (error) in
            DispatchQueue.main.async {
                self.chLabel.text = error.localizedDescription
            }
        }
        
        remonCall.onRetry { (completed) in
            print(completed)
        }
        
        remonCall.onRemoteVideoSizeChanged { (view, size) in
            print("Debug onRemoteVideoSizeChanged", size)
            print("Debug self.remonCall\(self.remonCall.remoteView.hashValue) and view\(view.hashValue) is same")
            
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
//                NOOP
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.remonCall.closeRemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
