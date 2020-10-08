//
//  RemonCast.swift
//  remonios
//
//  Created by hyounsiklee on 2018. 5. 10..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

/***/
@objc public class RemonCast: RemonClient {
    public override init() {
        super.init()
    }
    
    
    
    /// 시물캐스트 여부 : 방송
    @IBInspectable public var simulcast:Bool = false
    

    
    /**방송에 접속 합니다.
     - Parameters:
        - chId: 접속 하려는 방송의 채널 ID
        - config: 이 인자를 전달 하면 RemonCast의 설정이 무시 되고, config의 설정 값을 따릅니다.
     */
    @objc(joinWithChId:AndConfig:)
    public func join(chId: String, _ config:RemonConfig? ) {
        self.controller.joinCast(client:self, channelID: chId, config: config)
    }
    @objc(joinWithChId:)
    public func join(chId: String) {
        self.controller.joinCast(client:self, channelID: chId, config: nil)
    }
    
    /**방송을 생성 합니다.
     - Parameters:
        - name: 목록에 표시할 이름
        - channelId: 채널 아이디
        - config: 이 인자를 전달 하면 RemonCast의 설정이 무시 되고, config의 설정 값을 따릅니다.
     */
    @objc public func create(name:String, channelId:String, config:RemonConfig? = nil) {
        self.controller.createCast(client:self,name:name,channelID:channelId,config: config)
    }
    
    /**방송을 생성합니다.*/
    @objc public func create(_ config:RemonConfig? = nil) {
        create( name:"iOS", channelId: "", config: config)
    }
    
    
    /**방송 목록을 가져 옵니다.
     - Parameter complete: 패치 완료 블럭. error 인자가 nil 이라면 RemonSearchResult 목록을 전달 합니다.
     */
    @objc public func fetchCasts(complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        self.fetchChannel(type: .cast, roomName: nil) { (error, chs) in
            complete(chs)
        }
    }
    
}


@objc extension RemonCast{
    @objc public func onCreate(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            if let cast = self {
                let chType = cast.controller.context.channelType

                
                if chType == .broadcast {
                    block(cast.channelID)
                }
            }
        }
    }
    
    @objc public func onJoin(block: @escaping RemonStringBlock) {
        self.onComplete { [weak self] in
            if let cast = self {
                let chType = cast.controller.context.channelType

                if chType == .viewer {
                    block(cast.channelID)
                }
            }
        }
    }
    
    
    @objc public func onFetch(block: @escaping RemonArrayBlock) {
        self.onFetchChannels(block: block)
    }
    
}
