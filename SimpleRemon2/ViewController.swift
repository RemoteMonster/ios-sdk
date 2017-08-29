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
    
    var backImageView:UIImageView?
    var localVideoBackView:UIView?
    
    @IBOutlet weak var logbox: UITextView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var naviLeftBtn: UIBarButtonItem!
    
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var chIdView: UIView!
    @IBOutlet weak var chIdField: UITextField!
    
    @IBOutlet weak var dropBox: UIView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
//    MARK: IBAction 설정
    @IBAction func onDisconnectButton(_ sender: Any) {
        self.touchNaviLeftItem(self)
        localVideoBackView?.isHidden = false
        close()
    }
    

    @IBAction func onConnectMenuItemButton(_ sender: Any) {
        let rand:String! = String(arc4random_uniform(99999))
        chIdField.text = rand
        chIdView.alpha = 1.0
        dropBox.alpha = 0.0
        self.view.endEditing(true)
    }
    
    @IBAction func onCancelMenuItemButton(_ sender: Any) {
        chIdView.alpha = 0.0
        self.view.endEditing(true)
    }
    
    @IBAction func onConnectButton(_ sender: Any) {
        chIdView.alpha = 0.0
        let config = RemonConfig()
        config.key = "e3ee6933a7c88446ba196b2c6eeca6762c3fdceaa6019f03"
        config.serviceId = "simpleapp"
        //config.videoCall=false
        remon = Remon(delegate: self, config: config)
        self.view.endEditing(true)
    }
    
    @IBAction func touchNaviLeftItem(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if(self.dropBox.alpha == 1.0 || self.dropBox.alpha == 0.0){
                if self.dropBox.alpha == 1.0 {
                    self.dropBox.alpha = 0.0
                } else {
                    self.dropBox.alpha = 1.0
                }
            }else {
                return
            }
        }
    }
    
//    MARK: UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        self.navigationItem.title = "Remon Video Chat"
        
        
        backImageView = UIImageView(frame: self.view.frame)
        backImageView?.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
        backImageView?.image = UIImage(named: "remon_icon_1024.png")
        backImageView?.contentMode = UIViewContentMode.scaleAspectFit
        remoteView.addSubview(backImageView!)
        
        localVideoBackView = UIView(frame: CGRect(x: 0, y: 0, width: localView.frame.width, height: localView.frame.height))
        localVideoBackView?.backgroundColor = UIColor.black
        localView.addSubview(localVideoBackView!)
        
        var makeShadow : (_ view:UIView) -> Void
        
        makeShadow = {
            (_ view:UIView) -> Void in
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 1
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 10
        }
        
        makeShadow(dropBox)
        makeShadow(localView)
        makeShadow(chIdView)
        dropBox.alpha = 0.0
        chIdView.alpha = 0.0

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    MARK: Util func
    func close(){
        remon?.close()
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
    
    func log(msg:String){
        DispatchQueue.main.async{ [unowned self] in
            self.logbox.text = msg+"\n"+self.logbox.text
            self.logLabel.text = msg
        }
    }

//    MARK: RemonDelegate
    func onStateChange(_ state:RemonState){
        log(msg:"State: \(state)")
        print("state: \(state)")
        switch state{
        case RemonState.WAIT:
            log(msg: "Waiting for connection")
        case RemonState.CLOSE:
            close()
        case RemonState.FAIL:
            close()
        case RemonState.INIT:
            var chId:String! = chIdField.text
            if chId == nil || chId.characters.count == 0 {
                let rand:String! = String(arc4random_uniform(99999))
                chId = rand
            }
            remon?.connectChannel(chId: chId)
            self.navigationItem.title = chId
            //remon?.search(query:"")
        case RemonState.CONNECT:
            print ("Connecting")
            backImageView?.isHidden = true
            localVideoBackView?.isHidden = false
        case RemonState.COMPLETE:
            print ("Connected")
            backImageView?.isHidden = true
            localVideoBackView?.isHidden = false
        case RemonState.EXIT:
            print ("Exit")
    
        }
        
        
    }
    
    func didReceiveLocalVideoTrack(_ localVideoTrack:RTCVideoTrack){
        print ("********************* Local Video Track is occured *********************")
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(localView)
        localVideoBackView?.isHidden = true
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
        backImageView?.isHidden = false
        localVideoBackView?.isHidden = false
        self.navigationItem.title = "Remon Video Chat"
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
        backImageView?.isHidden = false
        localVideoBackView?.isHidden = false
        self.navigationItem.title = "Remon Video Chat"
        log(msg:"Close")
    }
    
}

