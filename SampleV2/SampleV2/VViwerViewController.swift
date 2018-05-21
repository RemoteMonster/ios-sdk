//
//  VViwerViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 30..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import Remon

class VViwerViewController: UIViewController {
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var initBtn: UIButton!
    @IBOutlet var remonController: RemonCast!
    @IBOutlet weak var chField: UITextField!
    
    @IBAction func joinBoardcast(_ sender: Any) {
        if let ch = self.chField.text {
            self.remonController.joinRoom(chID: ch)
        }
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
                self.view.endEditing(true)
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
