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
    
    
    @IBOutlet weak var chLabel_0: UILabel!
    @IBOutlet weak var chLabel_1: UILabel!
    @IBOutlet weak var chLabel_2: UILabel!
    @IBOutlet weak var chLabel_3: UILabel!
    @IBOutlet weak var chLabel_4: UILabel!
    @IBOutlet weak var chLabel_5: UILabel!
    
    @IBOutlet weak var chButton_0: UIButton!
    @IBOutlet weak var chButton_1: UIButton!
    @IBOutlet weak var chButton_2: UIButton!
    @IBOutlet weak var chButton_3: UIButton!
    @IBOutlet weak var chButton_4: UIButton!
    @IBOutlet weak var chButton_5: UIButton!
    
    @IBAction func endCh_0(_ sender: UIControl) {
        self.chButton_0.isEnabled = true
        self.disconnectChannel(label: self.chLabel_0, remon: remonCall_0)
    }
    
    @IBAction func endCh_1(_ sender: UIControl) {
        self.chButton_1.isEnabled = true
        self.disconnectChannel(label: self.chLabel_1, remon: remonCall_1)
    }
    
    @IBAction func endCh_2(_ sender: UIControl) {
        self.chButton_2.isEnabled = true
        self.disconnectChannel(label: self.chLabel_2, remon: remonCall_2)
    }
    
    @IBAction func endCh_3(_ sender: UIControl) {
        self.chButton_3.isEnabled = true
        self.disconnectChannel(label: self.chLabel_3, remon: remonCall_3)
    }
    
    @IBAction func endCh_4(_ sender: UIControl) {
        self.chButton_4.isEnabled = true
        self.disconnectChannel(label: self.chLabel_4, remon: remonCall_4)
    }
    
    @IBAction func endCh_5(_ sender: UIControl) {
        self.chButton_5.isEnabled = true
        self.disconnectChannel(label: self.chLabel_5, remon: remonCall_5)
    }
    
    
    @IBAction func goCh_0(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_0.text {
            self.connectChannel(chid: chid, label:self.chLabel_0, remon: remonCall_0)
        }
    }
    
    @IBAction func goCh_1(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_1.text {
            self.connectChannel(chid: chid, label:self.chLabel_1, remon: remonCall_1)
        }
    }
    
    @IBAction func goCh_2(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_2.text {
            self.connectChannel(chid: chid, label:self.chLabel_2, remon: remonCall_2)
        }
    }
    
    @IBAction func goCh_3(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_3.text {
            self.connectChannel(chid: chid, label:self.chLabel_3, remon: remonCall_3)
        }
    }
    
    @IBAction func goCh_4(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_4.text {
            self.connectChannel(chid: chid, label:self.chLabel_4, remon: remonCall_4)
        }
    }
    
    @IBAction func goCh_5(_ sender: UIControl) {
        sender.isEnabled = false
        if let chid = self.chField_5.text {
            self.connectChannel(chid: chid, label:self.chLabel_5, remon: remonCall_5)
        }
    }
    
    func connectChannel(chid:String, label:UILabel, remon:RemonCall) -> Void {
        remon.connect(chid)
        
        self.hideKeyboard()
        
        remon.onConnect { (chid) in
            DispatchQueue.main.async {
                label.text = chid
            }
            if let chid = chid {
                print("mesh connect", chid)
            } else {
                print("mesh connect", "dmd?")
            }
        }
        
        remon.onComplete {
            print("mesh complete")
        }
        
        remon.onClose { (type) in
            print("mesh close", type)
            
            DispatchQueue.main.async {
                label.text = ""
            }
        }
    }
    
    func disconnectChannel(label:UILabel, remon:RemonCall) -> Void {
        remon.closeRemon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
}

