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
        
        for view in self.view.subviews {
            if (view.tag == 999) {
                self.remonCall.remoteView = view;
            }
            
            if (view.tag == 888) {
                self.remonCall.localView = view;
            }
            
        }
        
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
        
        remonCall.onClose { (type) in
            DispatchQueue.main.async {
                self.chLabel.text = "Close Remon"
            }
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
