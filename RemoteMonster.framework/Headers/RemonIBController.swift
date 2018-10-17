//
//  RemonIBController.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

/***/
@objc(RemonIBController) @IBDesignable public class RemonIBController: RemonController {
//    @IBInspectable
    
    /***/
    public var channelType:Int {
        get {
            return channelType_
        }
        set(chtype) {
            self.channelType_ = chtype
        }
        
    }
    
    
    /***/
//    @IBInspectable
//    public var autoReJoin:Bool {
//        get {
//            return self.autoReJoin_
//        }
//        set(isAuto) {
//            self.autoReJoin_ = isAuto
//        }
//    }
    
    /***/
    @IBInspectable
    public var onlyAudio:Bool {
        get {
            return onlyAudio_
        }
        set(oa) {
            self.onlyAudio_ = oa
        }
    }
    
    //    @IBInspectable
    //    public var autoInit:Bool = false
    
    /***/
    @IBInspectable
    public var videoWidth:Int {
        get {
            return self.videoWidth_
        }
        set(vw) {
            self.videoWidth_ = vw
        }
    }
    
    /***/
    @IBInspectable
    public var videoHeight:Int{
        get {
            return self.videoHeight_
        }
        
        set(vh) {
            self.videoHeight_ = vh
        }
    }
    
    /***/
    @IBInspectable
    public var fps:Int {
        get {
            return self.fps_
        }
        set(fps) {
            self.fps_ = fps
        }
    }
    
    //    @IBInspectable
    //    public var remoteViewMirroring:Bool = true
    
    /***/
    @IBInspectable
    public var serviceId:String? {
        get {
            return self.serviceId_
        }
        set(sid) {
            self.serviceId_ = sid
        }
    }
    
    /***/
    @IBInspectable
    public var serviceKey:String? {
        get {
            return self.serviceKey_
        }
        set(skey) {
            self.serviceKey_ = skey
        }
    }
    
    /***/
    @IBInspectable
    public var wsUrl:String {
        get {
            return self.wsUrl_
        }
        
        set(url) {
            self.wsUrl_ = url
        }
    }
    
    /***/
    @IBInspectable
    public var restUrl:String {
        get {
            return self.restUrl_
        }
        
        set(url) {
            self.restUrl_ = url
        }
    }
    
    /***/
    @IBInspectable
    public var useFrontCamera:Bool {
        get {
            return self.useFrontCamera_
        }
        
        set(isFrontCamere) {
            self.useFrontCamera_ = isFrontCamere
        }
    }
    
    /*
    @IBInspectable
    public var audioType:RemonAudioMode {
        get {
            return self.audioType_
        }
        
        set(isFrontCamere) {
            self.audioType_ = audioType
        }
    }
    */
    
    //    IBOutlet
    /***/
    @IBOutlet dynamic public weak var remoteView:UIView? {
        didSet {
            self.remoteView_ = remoteView
        }
    }
    
    /***/
    @IBOutlet dynamic public var localView:UIView? {
        didSet {
            self.localView_ = localView
        }
    }
    
    /***/
    @IBOutlet dynamic public var localPreView:UIView? {
        didSet {
            self.localPreView_ = localPreView
        }
    }
}
