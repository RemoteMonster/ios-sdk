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
    func onFetch(block:@escaping RemonArrayBlock)
}

/**
 P2P 영상통화 클래스
 */
@objc public class RemonCall: RemonIBController, RemonCallBlockSettable {
    override public init() {
        print("[RemonCall.init]")
        super.init()
        self.channelType = RemonChannelType.p2p
    }
    
    /***/
    @objc public func connect(_ ch: String, _ config:RemonConfig? = nil) {
        print("[RemonCall.connect]" )
        controller?.connectCall( client:self, ch:ch, config:config)
    }
    
    /***/
    @objc public func fetchCalls(complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .call) { (error, chs) in
            complete(chs)
        }
    }
    
    
    
    // note:chance: 사용자에게 추가적인 인터페이스를 노출시키는데, 일관성이 떨어지는 것으로 판단됨.
    // 이미 배포된 버전들이 있어 일단은 유지
    /***/
    @objc public func onConnect(block: @escaping RemonStringBlock) {
        self.onCreate(block_: block)
    }
    
    /***/
    @objc public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
    
}
