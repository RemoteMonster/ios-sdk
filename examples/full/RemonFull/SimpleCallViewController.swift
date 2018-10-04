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
    
    
    @IBAction func ewf(_ sender: Any) {
        self.remonCall.showLocalVideoStat = true
        self.remonCall.showRemoteVideoStat = true
    }
    
    @IBAction func awedawef(_ sender: Any) {
        
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
        
        remonCall.onInit {
            DispatchQueue.main.async {
                self.boxView.isHidden = true
            }
        }
        
        remonCall.onComplete { () in
            DispatchQueue.main.async {
                self.chLabel.text = self.remonCall.channelID
            }
            
            self.remonCall.startDump(withFileName: "audio.aecdump", maxSizeInBytes: 100 * 1024)
        }
        
        remonCall.onClose {
            DispatchQueue.main.async {
                self.chLabel.text = "Close Remon"
            }
            
            self.remonCall.stopDump()
            
            self.remonCall.unpackAecDump(dumpName: "audio.aecdump", resultFileName: "unpack.m4a", progress: { (error, state) in
                
            })
        }
        
        remonCall.onConnect { (ss) in
            print(ss)
        }
        
        remonCall.onError { (error) in
            DispatchQueue.main.async {
                self.chLabel.text = error.localizedDescription
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
