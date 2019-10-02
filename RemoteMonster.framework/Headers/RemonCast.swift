//
//  RemonCast.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit


/**
 1:다 방송을 위한 클래스
 */
public protocol RemonCastBlockSettable {
    /** create() 호출 이후 방송 생성이 완료 되면 호출 됩니다.
     - Parameter block: 이 블럭의 string 인자는 생성된 채널의 ID 입니다.
     */
    func onCreate(block:@escaping RemonStringBlock)
    
    /** join() 호출 이후 방송 생성이 완료 되면 호출 됩니다.
     - Parameter block: 이 블럭의 string 인자는 접속을 시도한 채널의 ID 입니다.
     */
    func onJoin(block:@escaping RemonStringBlock)
    
    /** fetchCasts() 호출 이후 패치 작업이 완료 되면 호출 됩니다..
     - Parameter block: 이 블럭의  array 인자는 현재 접속 가능한 방송의 채널 ID 목록 입니다.
     */
    func onFetch(block:@escaping RemonArrayBlock)
}

/***/
@objc public class RemonCast: RemonClient, RemonCastBlockSettable {
    
    private var broardcast:Bool {
        get {
            if self.channelType == RemonChannelType.broadcast {
                return true
            } else {
                return false
            }
        }
        set(broardcast) {
            if broardcast {
                self.channelType = RemonChannelType.broadcast
            } else {
                self.channelType = RemonChannelType.viewer
            }
        }
    }
    
    override public init() {
        super.init()
        self.broardcast = true
    }
    
    /**방송에 접속 합니다.
     - Parameters:
        - chId: 접속 하려는 방송의 채널 ID
        - config: 이 인자를 전달 하면 RemonCast의 설정이 무시 되고, config의 설정 값을 따릅니다.
     */
    @objc(joinWithChId:AndConfig:)
    public func join(chId: String, _ config:RemonConfig? = nil) {
        self.broardcast = false
        controller?.joinCast(client:self, chID: chId, config: config)
    }
    @objc(joinWithChId:)
    public func objc_join(chId: String) {
        self.broardcast = false
        controller?.joinCast(client:self, chID: chId, config: nil)
    }
    
    /**방송을 생성 합니다.
     - Parameter config: 이 인자를 전달 하면 RemonCast의 설정이 무시 되고, config의 설정 값을 따릅니다.
     */
    @objc public func create(_ config:RemonConfig? = nil) {
        self.broardcast = true
        controller?.createCast(client:self, config: config)
    }
    
    /**방송 목록을 가져 옵니다.
     - Parameter complete: 패치 완료 블럭. error 인자가 nil 이라면 RemonSearchResult 목록을 전달 합니다.
     */
    @objc public func fetchCasts(complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .cast) { (error, chs) in
            complete(chs)
        }
    }
    
}


@objc extension RemonCast {
    @objc public func onCreate(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            if let cast = self {
                var chType = cast.channelType
                if let config = cast.remonConfig {
                    chType = config.channelType
                }
                if chType == .broadcast {
                    block(cast.channelID)
                }
            }
        }
    }
    
    @objc public func onJoin(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            if let cast = self {
                var chType = cast.channelType
                if let config = cast.remonConfig {
                    chType = config.channelType
                }
                if chType == .viewer {
                    block(cast.channelID)
                }
            }
        }
    }
    
    
    @objc public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
    
//    public func startCap(_ path:String) {
//        RTCStartInternalCapture(path)
//    }
//    
//    public func stopCap() {
//        RTCStopInternalCapture()
//    }
}
