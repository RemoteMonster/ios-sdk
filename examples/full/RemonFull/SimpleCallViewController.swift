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
    
    @IBOutlet weak var iuputGainSlider: UISlider!
    
//    change output!!!
    @IBAction func builtInReceiverOverideToSpeaker(_ sender: Any) {
        self.remonCall.builtInReceiverOverideToSpeaker = !self.remonCall.builtInReceiverOverideToSpeaker
    }
    
    @IBAction func changeInputSliderValue(_ sender: UISlider) {
        
        self.remonCall.setInpuGain(sender.value)
    }
    
    var customConfig:RemonConfig?
    
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
        self.iuputGainSlider.isEnabled = self.remonCall.inputGainSettable()
        remonCall.onInit {
            DispatchQueue.main.async {
                self.boxView.isHidden = true
            }
        }
        
        remonCall.onComplete { () in
            DispatchQueue.main.async {
                self.chLabel.text = self.remonCall.channelID
            }
            print("zzz", AVAudioSession.sharedInstance().currentRoute)
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
