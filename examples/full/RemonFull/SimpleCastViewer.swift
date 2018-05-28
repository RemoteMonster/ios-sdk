//
//  VViwerViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 30..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import Remon

class SimpleCastViewer: UIViewController {
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet var remonCast: RemonCast!
    
    var toChID:String?
    var customConfig:RemonConfig?
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            
        })
        self.chLabel.text = "closing..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let chID = self.toChID {
            //config is nilable
            self.remonCast.joinRoom(chID: chID, customConfig)
        }
        
        self.remonCast.onComplete {
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
        
        self.remonCast.onConnect {
            DispatchQueue.main.async {
                self.chLabel.text = "connect..."
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
