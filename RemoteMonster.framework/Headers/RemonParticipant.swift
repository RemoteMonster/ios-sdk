//
//  RemonParticipant.swift
//  RemoteMonster
//
//  Created by Chance Kim on 2019/11/13.
//  Copyright © 2019 Remote Monster. All rights reserved.
//

import Foundation


@objc public class RemonParticipant: RemonClient {
    /// 시물캐스트 여부 : 방송
    @IBInspectable public var simulcast:Bool = false

    
    override public init() {
        super.init()
    }
    
    /**
        
     */
    @objc(create:config:)
    public func create( name:String, _ config:RemonConfig? = nil) {
        controller?.createRoom(client:self, name: name, config: config)
    }
    
    /**
     
     */
    @objc(joinWithChId:config:)
    public func join(chId: String, _ config:RemonConfig? = nil) {
        controller?.joinCast(client:self, chID: chId, config: config)
    }
    
    /**
     
     */
    @objc(joinWithChId:)
    public func join(chId: String) {
        controller?.joinCast(client:self, chID: chId, config: nil)
    }
    
    /**
     목록을 가져 옵니다.
     - Parameter complete: 패치 완료 블럭. error 인자가 nil 이라면 RemonSearchResult 목록을 전달 합니다.
     */
    @objc public func fetchChannels(roomName:String, complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        
        self.fetchChannel(type: .room, roomName: roomName) { (error, chs) in
            complete(chs)
        }
    }
}

@objc extension RemonParticipant {
    @objc public func onCreate(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            print("[RemonParticipant.onCreate]")
            if let room = self {
                let chType = room.controller?.remon?.context.channelType
                if chType == .room {
                    block(room.channelID)
                }
            }
        }
    }
    
    @objc public func onJoin(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            print("[RemonParticipant.onJoin]")
            
            if let room = self {
                let chType = room.controller?.remon?.context.channelType
                if chType == .viewer {
                    block(room.channelID)
                }
            }
        }
    }
}
