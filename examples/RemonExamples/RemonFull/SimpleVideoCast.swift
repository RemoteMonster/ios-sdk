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
    @IBOutlet weak var captureView: UIImageView!
    
    var customConfig:RemonConfig?
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    @IBAction func createBoardcast(_ sender: Any) {
        //config is nilable
        self.remonCast.create(customConfig)
    }
    
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.remonCast.closeRemon()
    }
    
    @IBAction func viewCapture(_ sender: Any) {
        guard let localView = self.remonCast.localRTCEAGLVideoView else {
            return
        }
        let image = self.image(with: self.view)
        self.captureView.image = image
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
        
        self.remonCast.onClose { (_) in
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
