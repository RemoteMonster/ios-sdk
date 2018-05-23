//
//  VSimpleViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import Remon

class SimpleCallViewController: UIViewController {
    
    @IBOutlet var remonCall: RemonCall!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var chField: UITextField!
    @IBOutlet weak var chLabel: UILabel!
    
    @IBAction func touchConnectButton(_ sender: Any) {
        self.view.endEditing(true)
        let chid = self.chField.text
        if chid != nil && chid!.count > 0 {
            remonCall.connectChannel(chid!)
            self.chLabel.text = chid
        } else {
            let rand:String! = String(arc4random_uniform(9999))
            remonCall.connectChannel(rand)
            self.chLabel.text = rand
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        remonCall.onClose {
            DispatchQueue.main.async {
                self.chLabel.text = "Close Remon"
            }
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
