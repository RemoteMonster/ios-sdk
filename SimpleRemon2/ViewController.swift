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

public protocol RemonChCellDelegate{
    func onJoinRemonCh(_ item:Any)
}

class RemonChCell: UITableViewCell {
    
    var delegate:RemonChCellDelegate?
    
    @IBOutlet weak var chIDLabel: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    
    @IBAction func touchJoinButtn(_ sender: Any) {
        if delegate != nil {
            delegate?.onJoinRemonCh(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class ViewController: UIViewController , RemonDelegate, UITableViewDelegate, UITableViewDataSource, RemonChCellDelegate{

    var remon:Remon?
    var localVideoTrack:RTCVideoTrack?
    var remoteVideoTrack:RTCVideoTrack?
    
    var channels:Array<Any>?
    
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
    
    @IBOutlet weak var channelTableView: UITableView!
    
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
        touchNaviLeftItem(self)
        self.view.endEditing(true)
    }
    
    @IBAction func onCancelMenuItemButton(_ sender: Any) {
        chIdView.alpha = 0.0
        self.view.endEditing(true)
    }
    
    @IBAction func onConnectButton(_ sender: Any) {
        chIdView.alpha = 0.0
        self.view.endEditing(true)
        
        var chId:String! = chIdField.text
        if chId == nil || chId.characters.count == 0 {
            let rand:String! = String(arc4random_uniform(99999))
            chId = rand
        }
        remon?.connectChannel(chId: chId)
        self.navigationItem.title = chId
    }
    
    @IBAction func touchSearchButton (_ sender: Any) {
        remon?.search(query: "")
    }
    
    @IBAction func touchNaviLeftItem(_ sender: Any) {
        remon?.search(query: "")
        UIView.animate(withDuration: 0.3) {
//            let closeX:CGFloat = -200.0
//            let openX:CGFloat = 0.0
//            if(self.dropBox.frame.origin.x == openX || self.dropBox.frame.origin.x == closeX){
            if(self.dropBox.alpha == 1.0 || self.dropBox.alpha == 0.0){
                if self.dropBox.alpha == 1.0 {
                    self.dropBox.alpha = 0.0
//                    self.dropBox.frame.origin.x = closeX
                } else{
                    self.dropBox.alpha = 1.0
//                    self.dropBox.frame.origin.x = openX
                }
            }else {
                return
            }
        }
    }
    
//    MARK: UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initRemon()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1.00)
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
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            self.dropBox.alpha = 1.0
//            self.dropBox.frame = CGRect(x: -200, y: self.dropBox.frame.origin.y, width: self.dropBox.frame.size.width, height: self.dropBox.frame.size.height)
//        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    MARK: Util func
    func initRemon() {
        let config = RemonConfig()
        config.key = "e3ee6933a7c88446ba196b2c6eeca6762c3fdceaa6019f03"
        config.serviceId = "simpleapp"
        //config.videoCall=false
        remon = Remon(delegate: self, config: config)
    }
    
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
            localVideoBackView?.isHidden = true
        case RemonState.CLOSE:
            close()
        case RemonState.FAIL:
            close()
        case RemonState.INIT:
            print ("Init")
        case RemonState.CONNECT:
            print ("Connecting")
            backImageView?.isHidden = true
            localVideoBackView?.isHidden = true
        case RemonState.COMPLETE:
            print ("Connected")
            backImageView?.isHidden = true
            localVideoBackView?.isHidden = true
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
        initRemon()
    }
    
    func onError(_ error:RemonError){
        print ("onError is called")
        log (msg: "Error: \(error.localizedDescription)")
        initRemon()
    }
    
    func onMessage(_ message:String){
        log(msg: message)
    }
    
    func onSearch(_ result:Array<[String:String]>){
//        for ch in result{
//            print(ch["id"]!)
//        }
        self.channels = result
        self.channelTableView.reloadData()
    }
    
    func onClose(){
        backImageView?.isHidden = false
        localVideoBackView?.isHidden = false
        self.navigationItem.title = "Remon Video Chat"
        log(msg:"Close")
        initRemon()
    }
    
    
    
//    MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channels != nil && (self.channels?.count)! > 0 {
            return (self.channels?.count)!;
        }
        
        return 0;
        
    }
    
    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "remonChCell", for: indexPath)
        let chDict:Dictionary<String, Any> = self.channels?[indexPath.row] as! Dictionary<String, Any>
        
        let remonCell:RemonChCell = cell as! RemonChCell
        remonCell.chIDLabel?.text =  chDict["id"] as? String
        remonCell.delegate = self as RemonChCellDelegate
        
        return cell
    }
    
    func onJoinRemonCh(_ item:Any){
        let remonCell:RemonChCell = item as! RemonChCell
        remon?.connectChannel(chId: remonCell.chIDLabel.text!)
        self.navigationItem.title = remonCell.chIDLabel.text!
        
        touchNaviLeftItem(self)
    }
    
}

