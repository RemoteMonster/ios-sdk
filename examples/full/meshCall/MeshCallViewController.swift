//
//  ViewController.swift
//  meshCall
//
//  Created by lhs on 14/01/2019.
//  Copyright © 2019 Remon. All rights reserved.
//

import UIKit
import RemoteMonster

class MeshCallViewController: UIViewController {
    
    @IBOutlet var remonCall_0: RemonCall!
    @IBOutlet var remonCall_1: RemonCall!
    @IBOutlet var remonCall_2: RemonCall!
    @IBOutlet var remonCall_3: RemonCall!
    @IBOutlet var remonCall_4: RemonCall!
    @IBOutlet var remonCall_5: RemonCall!
    
    @IBOutlet weak var chField_0: UITextField!
    @IBOutlet weak var chField_1: UITextField!
    @IBOutlet weak var chField_2: UITextField!
    @IBOutlet weak var chField_3: UITextField!
    @IBOutlet weak var chField_4: UITextField!
    @IBOutlet weak var chField_5: UITextField!
    
    
    @IBAction func goCh_0(_ sender: UIControl) {
        if let chid = self.chField_0.text {
            self.connectChannel(chid: chid, remon: remonCall_0)
        }
    }
    
    @IBAction func goCh_1(_ sender: UIControl) {
        if let chid = self.chField_1.text {
            self.connectChannel(chid: chid, remon: remonCall_1)
        }
    }
    
    @IBAction func goCh_2(_ sender: UIControl) {
        if let chid = self.chField_2.text {
            self.connectChannel(chid: chid, remon: remonCall_2)
        }
    }
    
    @IBAction func goCh_3(_ sender: UIControl) {
        if let chid = self.chField_3.text {
            self.connectChannel(chid: chid, remon: remonCall_3)
        }
    }
    
    @IBAction func goCh_4(_ sender: UIControl) {
        if let chid = self.chField_4.text {
            self.connectChannel(chid: chid, remon: remonCall_4)
        }
    }
    
    @IBAction func goCh_5(_ sender: UIControl) {
        if let chid = self.chField_5.text {
            self.connectChannel(chid: chid, remon: remonCall_5)
        }
    }
    
    func connectChannel(chid:String, remon:RemonCall) -> Void {
        remon.connect(chid)
        
        remon.onConnect { (chid) in
            print("mesh connect", chid)
        }
        
        remon.onComplete {
            print("mesh complete")
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

