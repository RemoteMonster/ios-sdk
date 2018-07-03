//
//  ConfigViewController.swift
//  RemonFull
//
//  Created by hyounsiklee on 2018. 5. 28..
//  Copyright © 2018년 Remon. All rights reserved.
//

import UIKit
import RemoteMonster

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var serviceIDField: UITextField!
    @IBOutlet weak var serviceKeyField: UITextField!
    @IBOutlet weak var videoCallSegment: UISegmentedControl!
    @IBOutlet weak var codecField: UITextField!
    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var fpsField: UITextField!
    @IBOutlet weak var autoCaptureStartSegment: UISegmentedControl!
    @IBOutlet weak var channelTypeSegment: UISegmentedControl!
    @IBOutlet weak var userFrontCamaraSegment: UISegmentedControl!
    @IBOutlet weak var audioModeSegment: UISegmentedControl!
    @IBOutlet weak var debugModeSegment: UISegmentedControl!
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func next(_ sender: Any) {
        let config = RemonConfig()
        
        guard let sid:String = self.serviceIDField.text,
            let skey:String = self.serviceKeyField.text,
            let vCall:Bool = self.videoCallSegment.selectedSegmentIndex == 0,
            let codec:String = self.serviceIDField.text,
            let width:Int = Int(self.widthField.text!),
            let height:Int = Int(self.heightField.text!),
            let fps:Int = Int(self.fpsField.text!),
            let autoCapture:Bool = self.autoCaptureStartSegment.selectedSegmentIndex == 0,
            let chType:Int = self.channelTypeSegment.selectedSegmentIndex,
            let frontCametra:Bool = self.userFrontCamaraSegment.selectedSegmentIndex == 0,
            let audioMode:RemonAudioMode = self.audioModeSegment.selectedSegmentIndex == 0 ? .voice : .music,
            let debugMode:Bool = self.debugModeSegment.selectedSegmentIndex == 0
            else {
                let al = UIAlertController(title: nil, message: "모든 값을 입력해 주세요", preferredStyle: .alert)
                let ac = UIAlertAction(title: "OK", style: .cancel) { (ac) in}
                al.addAction(ac)
                self.present(al, animated: true, completion: nil)
                return
        }
        
        config.serviceId = sid
        config.key = skey
        config.videoCall = vCall
        config.videoCodec = codec
        config.videoWidth = width
        config.videoHeight = height
        config.videoFps = fps
        config.autoCaptureStart = autoCapture
        config.useFrontCamera = frontCametra
//        config.audioType = audioMode
        config.restUrl = "https://matiz.remotemonster.com/rest/init"
        config.wsUrl = "wss://matiz.remotemonster.com/ws"
        config.debugMode = debugMode
        switch chType {
        case 0:
            config.channelType = .p2p
        case 1:
            config.channelType = .viewer
        case 2:
            config.channelType = .broadcast
        default:
            config.channelType = .p2p
        }
        
        
        if config.channelType == .p2p {
            let callVC:SimpleCallViewController = self.storyboard?.instantiateViewController(withIdentifier: "SimpleCallViewController") as! SimpleCallViewController
            callVC.customConfig = config
            self.show(callVC, sender: self)
        }
        
        if config.channelType == .viewer {
            let searchVC:SampleSerchTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "SampleSerchTableViewController") as! SampleSerchTableViewController
            searchVC.customConfig = config
            self.show(searchVC, sender: self)
        }
        
        if config.channelType == .broadcast {
            if config.videoCall {
                let castVC:SimpleVideoCast = self.storyboard?.instantiateViewController(withIdentifier: "SimpleVideoCast") as! SimpleVideoCast
                castVC.customConfig = config
                self.show(castVC, sender: self)
            } else {
                let castVC:SimpleVoiceCast = self.storyboard?.instantiateViewController(withIdentifier: "SimpleVoiceCast") as! SimpleVoiceCast
                castVC.customConfig = config
                self.show(castVC, sender: self)
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
