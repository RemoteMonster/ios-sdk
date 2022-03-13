//
//  RemonCall.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

/**
 P2P 영상통화 클래스
 */
@objc public class RemonCall: RemonClient {
    public override init() {
        print("[RemonCall.init]")
        super.init()
    }
    
    
    /***/
    @objc public func connect(_ ch: String, _ config:RemonConfig? = nil) {
        print("[RemonCall.connect]" )
        self.controller.connectCall( client:self, channelID:ch, config:config)
    }
    
    /***/
    @objc public func fetchCalls(complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .call, roomName: nil) { (error, chs) in
            complete(chs)
        }
    }
}

@objc extension RemonCall {
    /***/
    @objc public func onConnect(block: @escaping RemonStringBlock) {
        self.onCreateInternal(block: block)
    }
    
    /***/
    @objc public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
}
