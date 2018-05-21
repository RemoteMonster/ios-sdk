//
//  ViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 25..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import Remon

class VViewController: UIViewController, RemonDelegate{
    //    MARK: RemonDelegate 구현
//    RemonManagerDelegate 보다 많은 정보가 필요 하다면 remonDelegate를 구현 하여 사용 할 수 있습니다.
    func onStateChange(_ state: RemonState) {
        
    }
    
    func didReceiveLocalVideoTrack(_ localVideoTrack: RTCVideoTrack) {
        
    }
    
    func didReceiveLocalAudioTrack(_ localAudioTrack: RTCAudioTrack) {
        
    }
    
    func didReceiveLocalVideoCapture(_ localVideoCaptur: RTCCameraVideoCapturer) {
        
    }
    
    func didReceiveRemoteVideoTrack(_ remoteVideoTrack: RTCVideoTrack) {
        
    }
    
    func didReceiveRemoteAudioTrack(_ remoteAudioTrack: RTCAudioTrack) {
        
    }
    
    func onError(_ error: RemonError) {
        
    }
    
    func onMessage(_ message: String) {
        
    }
    
    func onSearch(_ result: Array<[String : String]>) {
        
    }
    
    func onCreateChannel(channelID: String) {
        
    }
    
    func onDisconnectChannel(_ chID: String?) {
        
    }
    
    func onClose() {
        
    }
    

    @IBOutlet var remonBController: RemonController! {
        didSet (r) {
            r.legacyDelegate = self
        }
    }
    
    @IBOutlet var remonCController: RemonController!
        {
        didSet (r){
            r.legacyDelegate = self
        }
    }
    
    @IBOutlet var remonVController: RemonController!{
        didSet (r) {
            r.legacyDelegate = self
        }
    }
    
    @IBOutlet weak var broadCastInitBtn: UIButton!
    @IBOutlet weak var comInitBtn: UIButton!
    @IBOutlet weak var viewerInitBtn: UIButton!
    
    @IBOutlet weak var roomField: UITextField!
    @IBOutlet weak var room2Field: UITextField!
    
    @IBAction func createCh(_ sender:UIButton) {
        if let ch = self.roomField.text {
            
        }
        self.view.endEditing(true)
    }
    
    @IBAction func joinCh(_ sender:UIButton) {
        if let ch = self.room2Field.text {
            
        }
        self.view.endEditing(true)
    }
    
    @IBAction func hideKeyboard(_ sender:UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func joinBoardcast(_ sender:UIButton) {
        if let ch = self.room2Field.text {
            
        }
        self.view.endEditing(true)
    }
    
    @IBAction func createBoardcast(_ sender:UIButton) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func close(_ sender:UIButton) {
        
        self.room2Field.text = ""
        self.roomField.text = ""
        self.view.endEditing(true)
    }
    
    @IBAction func initRemon(_ sender:UIButton) {
        sender.isEnabled = false
        
    }
    
    @IBAction func m(_ sender:UIButton) {
//        remonManager.mirroringRemoteView(true)
    }
    
    @IBAction func um(_ sender:UIButton) {
//        remonManager.mirroringRemoteView(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

