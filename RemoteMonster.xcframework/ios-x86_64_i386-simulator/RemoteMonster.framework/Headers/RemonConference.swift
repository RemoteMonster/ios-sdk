//
//  RemonConference.swift
//  SimpleConference
//
//  Created by Chance Kim on 2019/11/20.
//  Copyright © 2019 remote monster. All rights reserved.
//

import Foundation
import os

public typealias OnConferenceErrorCallback = (_ error:RemonError) -> Void
public typealias OnConferenceCloseCallback = () -> Void
public typealias OnConferenceEventCallback = (_ participant:RemonParticipant) -> Void


/**
 */
public class RemonConferenceCallbacks {
    var errorCallback:OnConferenceErrorCallback?
    var closeCallback:OnConferenceCloseCallback?
    var eventCallbacks = Dictionary<String, OnConferenceEventCallback>()
    
    
    /**
     
     */
    @discardableResult
    public func on( eventName:String, callback:@escaping OnConferenceEventCallback ) -> RemonConferenceCallbacks {
        self.eventCallbacks[eventName] = callback
        return self
    }
    
    /**
     
     */
    @discardableResult
    public func close( callback:@escaping OnConferenceCloseCallback ) -> RemonConferenceCallbacks {
        self.closeCallback = callback
        return self
    }
    
    /**
     
     */
    @discardableResult
    public func error( callback:@escaping OnConferenceErrorCallback ) -> RemonConferenceCallbacks {
        self.errorCallback = callback
        return self
    }
}




/**
 
 */
@objc
public class RemonConference : NSObject {
    let log = OSLog(subsystem: "RemonConference", category: "RemonClient")

    private var participants = Dictionary<String, RemonParticipant>()
    public var me:RemonParticipant?
    
    private var roomName:String?
    private var defaultConfig:RemonConfig?
    
    private var conferenceCallbacks = RemonConferenceCallbacks()
    

    public override init() {
        
    }
    
    public func create(roomName:String, config:RemonConfig, callback:OnConferenceEventCallback) -> RemonConferenceCallbacks {
        self.roomName = roomName
        self.defaultConfig = config
        
        for participant in self.participants.values {
            participant.close()
        }
        self.participants.removeAll()
        
        let master = self.createSender(roomName: roomName, config: config)
        callback(master)
        
        master.onRoomEvent(block: { [weak self] (type, channelName) in
            self?.onParticipant(type: type, channelName: channelName)
        })
        
        master.connect()
        return self.conferenceCallbacks
    }
    

    public func leave() {
        for participant in self.participants.values {
            participant.close()
        }
        self.participants.removeAll()
        
        if let master = self.me {
            master.close()
        }
        self.me = nil
    }
    

    
    func fetchChannelsInRoom() {
        print("[RemonConference] fetchChannels")
        guard let master = self.me, let roomName = self.roomName else {
            return
        }
        
    
        master.fetchChannelsInRoom(roomName: roomName, complete: { [weak self] list in
            guard let channelList = list else {
                return
            }
            
            for item in channelList {
                DispatchQueue.main.async { [weak self, item] in
                    self?.onParticipant(type: "join", channelName: item.chId)
                }
            }
        })
    }
    
    func onParticipant( type:String, channelName:String ) {
        print("[RemonConference] onParticipant:type=\(type),channelName=\(channelName)")
        if type == "leave" {
            if let participant = self.participants.removeValue(forKey: channelName) {
                let eventCallback = self.conferenceCallbacks.eventCallbacks["onUserLeaved"]
                if eventCallback != nil {
                    eventCallback!(participant)
                }
                
                participant.close()
            }
        } else if type == "join" {
            guard let masterClient = self.me  else {
                print("[RemonConference] master client is not available")
                return
            }
            
            if masterClient.id == channelName {
                return
            }
            
            if self.participants[channelName] != nil {
                return
            }
    
            let participant = self.createViewer(channelId: channelName, config: self.defaultConfig)
            let eventCallback = self.conferenceCallbacks.eventCallbacks["onUserJoined"]
            if eventCallback != nil {
                eventCallback!(participant)
            }
            participant.connect()
        }
    }
    
    func onCreateMasterParticipant( participant:RemonParticipant? ) {
        if let _participant = participant, let callback = self.conferenceCallbacks.eventCallbacks["onRoomCreated"] {
            callback(_participant)
            self.fetchChannelsInRoom()
        }
    }
    
    func onErrorMasterParticipant( error:RemonError ) {
        if let callback = self.conferenceCallbacks.errorCallback {
            callback(error)
        }
    }
    
    func onCloseMasterParticipant( participant:RemonParticipant? ) {
        if let callback = self.conferenceCallbacks.closeCallback{
            callback()
        }
    }
    
    func createViewer( channelId:String, config:RemonConfig?)->RemonParticipant{
        let participant = RemonParticipant( conference: self, type: .SUBSCRIBE, config: config, channelId: channelId)
        participant.createPeer()
        self.participants[channelId] = participant
        return participant
    }
    
    func createSender( roomName:String, config:RemonConfig? )->RemonParticipant {
        let participant = RemonParticipant( conference: self, type: .PUBLISH, config: config, channelId: roomName)
        participant.createPeer()
        self.me = participant
        return participant
    }
}
