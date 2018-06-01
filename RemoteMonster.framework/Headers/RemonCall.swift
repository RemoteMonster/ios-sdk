//
//  RemonCall.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

/***/
public protocol RemonCallBlockSettable {
    func onConnect(block:@escaping RemonStringBlock)
    func onComplete(block:@escaping RemonVoidBlock)
    func onFetch(block:@escaping RemonArrayBlock)
}

/***/
public class RemonCall: RemonIBController, RemonControllBlockSettable, RemonCallBlockSettable {
    override public init() {
        super.init()
        self.channelType = 0
    }
    
    /***/
    public func connect(_ ch: String, _ config:RemonConfig? = nil) {
        self.connectCall(ch, config)
    }
    
    /***/
    public func fetchCalls(complete: @escaping (RemonError?, Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .call, complete: complete)
    }
    
    /***/
    public func onConnect(block: @escaping RemonStringBlock) {
        self.onCreate(block_: block)
    }
    
    /***/
    public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
    
    override public func onComplete(block: @escaping RemonVoidBlock) {
        super.onComplete(block: block)
    }
}
