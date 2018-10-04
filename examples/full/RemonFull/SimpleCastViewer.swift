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
        }
        
        self.remonCast.onInit {
            DispatchQueue.main.async {
                self.chLabel.text = "init..."
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.remonCast.closeRemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
