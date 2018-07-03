//
//  VCasterViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleVideoCast:UIViewController {
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var remonLocalView: UIView!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet var remonCast: RemonCast!
    
    var customConfig:RemonConfig?
    
    @IBAction func createBoardcast(_ sender: Any) {
        //config is nilable
        self.remonCast.create(customConfig)
    }
    
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.remonCast.closeRemon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.remonCast.onInit {
            self.createBtn.isEnabled = false
        }
        
        self.remonCast.onCreate { (chid) in
            DispatchQueue.main.async {
                self.closeBtn.isEnabled = true
                self.chLabel.text = chid
                
            }
        }
        
        self.remonCast.onClose {
            self.createBtn.isEnabled = true
            self.closeBtn.isEnabled = false
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
