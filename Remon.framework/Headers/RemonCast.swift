//
//  RemonCast.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

public class RemonCast: RemonIBController, RemonControllBlockSettable {
    @IBInspectable public var broardcast:Bool {
        get {
            if self.channelType_ == 2 {
                return true
            } else {
                return false
            }
        }
        set(broardcast) {
            if broardcast {
                self.channelType = 2
            } else {
                self.channelType = 1
            }
        }
    }
    
    override public init() {
        super.init()
        self.broardcast = true
    }
    
    override public func joinRoom(chID: String, _ config:RemonConfig? = nil) {
        super.joinRoom(chID: chID, config)
    }
    
    override public func createRoom(_ config:RemonConfig? = nil) {
        super.createRoom(config)
    }
    
    public func search(complete: @escaping (RemonError?, Array<RemonSearchResult>?) -> Void) {
        super.search(type: .cast, complete: complete)
    }
}
