//
//  VCasterViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import Remon

class VCasterViewController: UIViewController {
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var initBtn: UIButton!
    @IBOutlet var remonController: RemonCast!
    @IBOutlet weak var chField: UITextField!
    @IBAction func createBoardcast(_ sender: Any) {
        self.remonController.createRoom()
    }
    
    @IBAction func initRemonManager(_ sender: Any) {
        
    }
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.remonController.closeRemon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.remonController.onComplete {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.remonController.closeRemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
