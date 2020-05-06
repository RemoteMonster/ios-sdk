//
//  RemonParticipant.swift
//  RemoteMonster
//
//  Created by Chance Kim on 2019/11/13.
//  Copyright © 2019 Remote Monster. All rights reserved.
//

import Foundation


public typealias OnParticipantEventCallback = (_ participant:RemonParticipant ) -> Void


@objc public class RemonParticipant: RemonClient {
    @objc public enum ParticipantType:Int {
        case PUBLISH
        case SUBSCRIBE
    }
    
    
    public var id:String
    public var type:ParticipantType
    public var tag:Any?
    
    public var simulcast:Bool = false

    private weak var remonConference:RemonConference?
    private var latestError:RemonError?
    private var eventCallbacks = Dictionary<String, OnParticipantEventCallback>()
    
    
    
    
    public init(conference:RemonConference, type:ParticipantType, config:RemonConfig?, channelId:String ) {
        remonConference = conference
        self.type = type
        self.id = channelId
        
        super.init()
        
        if config != nil {
            self.remonConfig.setConfig(other: config!)
        }
        
    }
    
    @discardableResult
    public func on( event:String, callback:@escaping OnParticipantEventCallback)->RemonParticipant {
        eventCallbacks[event] = callback
        return self
    }
    
    
    public func getLatestError()->RemonError? {
        return latestError
    }
    
    
    
    func createPeer() {
        switch(self.type) {
        case .PUBLISH:
            initCast()
            
        case .SUBSCRIBE:
            initCastViewer()
        }
    }
    
    
    public func close() {
        super.closeRemon()
        
        eventCallbacks.removeAll()
        remonConference = nil
        tag = nil
    }
    
    
    
    private func initCast() {
        print("[RemonParticipant.initCast]")
        
        self.onCreateInternal { [weak self] channelId in
            print("[RemonParticipant.onCreate]")
            if let senderChannelId = channelId {
                self?.id = senderChannelId
            }
        }
        
        self.onComplete {
            [weak self] in
            if let participant = self {
                participant.remonConference?.onCreateMasterParticipant(participant:participant)
            }
        }
        
        self.onClose { [weak self] _ in
            if let participant = self {
                participant.remonConference?.onCloseMasterParticipant(participant:participant)
            }
        }
        
        self.onError { [weak self](error) in
            self?.latestError = error
            if let participant = self {
                participant.remonConference?.onErrorMasterParticipant(error: error)
            }
        }
    }
    
    private func initCastViewer() {
        print("[RemonParticipant.initCastViewer]")
        self.onComplete {
            [weak self] in
            if let participant = self {
                participant.remonConference?.onParticipantConnected(participant: participant)
                
                if let callback = self?.eventCallbacks["onComplete"] {
                    callback(participant)
                }
            }
        }
        
        self.onClose {
            [weak self]_ in
            if let participant = self, let callback = self?.eventCallbacks["onClose"] {
                callback(participant)
            }
        }
        
        self.onError {
            [weak self](error) in
            self?.latestError = error
            if let participant = self {
                if let callback = self?.eventCallbacks["onError"] {
                    callback(participant)
                }
            }
        }
    }
    
    
    func connect() {
        switch(self.type) {
        case .PUBLISH:
            controller?.createRoom(client:self, name: self.id, config: nil)
            
            
        case .SUBSCRIBE:
            controller?.joinCast(client:self, chID: self.id, config: nil)
        }
    }
    
    

    /**
     목록을 가져 옵니다.
     - Parameter complete: 패치 완료 블럭. error 인자가 nil 이라면 RemonSearchResult 목록을 전달 합니다.
     */
    @objc public func fetchChannelsInRoom(roomName:String, complete: @escaping (Array<RemonSearchResult>?) -> Void) {
        
        self.fetchChannel(type: .room, roomName: roomName) { (error, chs) in
            complete(chs)
        }
    }
}


