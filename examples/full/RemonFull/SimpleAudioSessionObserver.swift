//
//  SimpleAudioSessionDelegate.swift
//  RemonFull
//
//  Created by hsik on 03/07/2018.
//  Copyright © 2018 Remon. All rights reserved.
//

import UIKit
import AVKit

class SimpleAudioSessionObserver: NSObject {
    override init() {
        super.init()
        self.setupNotifications()
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRouteChange),
                                       name: .AVAudioSessionRouteChange,
                                       object: nil)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
                return
        }
        
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs {
                print("새로운 디바이스",output.portType)
            }
            
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs {
                    print("이전 디바이스", output.portType)
                }
            }
            
        default: ()
        }
    }
}
