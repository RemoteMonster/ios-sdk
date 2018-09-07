//
//  RemonCall.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

/***/
@objc public protocol RemonCallBlockSettable {
    func onConnect(block:@escaping RemonStringBlock)
    func onComplete(block:@escaping RemonVoidBlock)
    func onFetch(block:@escaping RemonArrayBlock)
}

/***/
@objc public class RemonCall: RemonIBController, RemonControllBlockSettable, RemonCallBlockSettable {
    override public init() {
        super.init()
        self.channelType = 0
    }
    
    /***/
    @objc public func connect(_ ch: String, _ config:RemonConfig? = nil) {
        self.connectCall(ch, config)
    }
    
    /***/
    public func fetchCalls(complete: @escaping (RemonError?, Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .call, complete: complete)
    }
    
    public func fetchCalls(restUrl:String?, complete: @escaping (RemonError?, Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .call, restUrl:restUrl, complete: complete)
    }
    
    /***/
    @objc public func onConnect(block: @escaping RemonStringBlock) {
        self.onCreate(block_: block)
    }
    
    /***/
    @objc public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
    
    @objc override public func onComplete(block: @escaping RemonVoidBlock) {
        super.onComplete(block: block)
    }
}
