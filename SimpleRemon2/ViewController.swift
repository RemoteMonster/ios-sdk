//
//  ViewController.swift
//  SimpleRemon2
//
//  Created by 최진호 on 2017. 2. 1..
//  Copyright © 2017년 Remote Monster. All rights reserved.
//

import UIKit
import WebRTC
import remonios

class ViewController: UIViewController , RemonDelegate{

    var remon:Remon?
    var localVideoTrack:RTCVideoTrack?
    var remoteVideoTrack:RTCVideoTrack?
    
    @IBOutlet weak var logbox: UITextView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    
    
    @IBAction func onDisconnectButton(_ sender: Any) {
        close()
    }
    
    @IBAction func onConnectButton(_ sender: Any) {
        let config = RemonConfig()
        config.key = "e3ee6933a7c88446ba196b2c6eeca6762c3fdceaa6019f03"
        config.serviceId = "simpleapp"
        //config.videoCall=false
        
        remon = Remon(delegate: self, config: config)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close(){
        remon?.disconnect()
        if let rvt = self.remoteVideoTrack{
            if (rvt.accessibilityElementCount())>0{
                rvt.remove(remoteView)
            }
        }
        if let lvt = self.localVideoTrack{
            if (lvt.accessibilityElementCount())>0{
                lvt.remove(localView)
            }
        }
    }

    func onStateChange(_ state:RemonState){
        log(msg:"State: \(state)")
        print("state: \(state)")
        switch state{
        case RemonState.CLOSE:
            close()
        case RemonState.FAIL:
            close()
        case RemonState.INIT:
            remon?.connectChannel(chId: "demo1")
            //remon?.search(query:"")
        case RemonState.CONNECT:
            print ("RemonState.connect ")
        case RemonState.COMPLETE:
            print ("RemonState.complete")
        case RemonState.EXIT:
            print ("RemonState.exit")
        default:
            log(msg:"Unknowned state ")
            
        }
        
        
    }
    func didReceiveLocalVideoTrack(_ localVideoTrack:RTCVideoTrack){
        print ("********************* Local Video Track is occured *********************")
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(localView)
    }
    func didReceiveRemoteVideoTrack(_ remoteVideoTrack:RTCVideoTrack){
        print ("********************* Remote Video Track is occured *********************")
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.add(remoteView)
        //self.remon?.switchCamera()
    }
    func onDisconnectChannel() {
        log(msg:"onDisconnectChannel is called")
        print ("onDisconnectChannel is called")
        //close()
    }
    func onError(_ error:RemonError){
        print ("onError is called")
        log (msg: "Error: \(error.localizedDescription)")
        
    }
    func onMessage(_ message:String){
        log(msg: message)
    }
    func onSearch(_ result:Array<[String:String]>){
        for ch in result{
            print(ch["id"]!)
        }
    }
    func onClose(){
        
    }
    func log(msg:String){
        DispatchQueue.main.async{ [unowned self] in
            self.logbox.text = msg+"\n"+self.logbox.text
        }
    }
}

