//
//  RemonConference.swift
//  SimpleConference
//
//  Created by Chance Kim on 2019/11/20.
//  Copyright © 2019 remote monster. All rights reserved.
//

import Foundation
import os

public typealias OnInitializedCallback = (_ client:RemonParticipant) -> Void
public typealias OnCreateMasterUserCallback = (_ client:RemonParticipant) -> Void
public typealias OnUserJoinedCallback = (_ channelName:String,_ slotIndex:Int, _ client:RemonParticipant) -> Void
public typealias OnCreatedRemoteUserCallback = (_ index:Int,_ client:RemonParticipant) -> Void

/**
 */
public protocol RemonConferenceViewer {
    func on( callback:@escaping OnUserJoinedCallback ) -> RemonConferenceViewerCallbacks
}


/**
 */
public class RemonConferenceMasterCallbacks {
    var createCallback:RemonStringBlock?
    var closeCallback:RemonVoidBlock?
    var errorCallback:RemonErrorBlock?
    
    /**
     
     */
    @discardableResult
    public func then( callback:@escaping RemonStringBlock ) -> RemonConferenceMasterCallbacks {
        self.createCallback = callback
        return self
    }
    
    /**
     
     */
    @discardableResult
    public func close( callback:@escaping RemonVoidBlock ) -> RemonConferenceMasterCallbacks {
        self.closeCallback = callback
        return self
    }
    
    /**
     
     */
    @discardableResult
    public func error( callback:@escaping RemonErrorBlock ) -> RemonConferenceMasterCallbacks {
        self.errorCallback = callback
        return self
    }
}

/**
 
 */
public class RemonConferenceViewerCallbacks {
    var joinCallback:RemonStringBlock?
    var closeCallback:RemonVoidBlock?
    var errorCallback:RemonErrorBlock?
    
    @discardableResult
    public func then( callback:@escaping RemonStringBlock ) -> RemonConferenceViewerCallbacks {
        self.joinCallback = callback
        return self
    }
    
    @discardableResult
    public func close( callback:@escaping RemonVoidBlock ) -> RemonConferenceViewerCallbacks {
        self.closeCallback = callback
        return self
    }
    
    @discardableResult
    public func error( callback:@escaping RemonErrorBlock ) -> RemonConferenceViewerCallbacks {
        self.errorCallback = callback
        return self
    }
}


/**
 
 */
@objc
public class RemonConference : NSObject {
    let remonConferenceInternal = RemonConferenceInternal()
    
    public override init() {
        
    }
    
    /**
     
     */
    public func create(callback:OnInitializedCallback) -> RemonConferenceMasterCallbacks {
        return self.remonConferenceInternal.create( callback:callback )
    }
    
    /**
     
     */
    public func join( roomName:String ) -> RemonConferenceViewer {
        return self.remonConferenceInternal.join(roomName: roomName)
    }
    
    /**
     
     */
    public func leave() {
        self.remonConferenceInternal.closeAll()
    }
    
    public func getClient( index:Int) -> RemonClient? {
        return self.remonConferenceInternal.get(index: index)?.client
    }

}



class RemonConferenceInternal : RemonConferenceViewer {
    let log = OSLog(subsystem: "RemonConference", category: "RemonClient")
    let locker = NSLock()
    let MAX_USER_COUNT = 6
    
    struct RemonSlotItem {
        var name:String?
        var client:RemonParticipant?
    }
    
    private var conferenceArray:Array<RemonSlotItem> = Array()
    private var roomName:String = ""
    private var timer:Timer?
    
    private var userJoinedCallback:OnUserJoinedCallback?
    private var masterCallback:RemonConferenceMasterCallbacks?
    private var userCallback:RemonConferenceViewerCallbacks?
    
    
    internal init() {
        for _ in 0..<MAX_USER_COUNT {
            conferenceArray.append(RemonSlotItem())
        }
    }
    
    public func on( callback:@escaping OnUserJoinedCallback ) -> RemonConferenceViewerCallbacks {
        userJoinedCallback = callback
        userCallback = RemonConferenceViewerCallbacks()
        return userCallback!
    }
    
    
    
    // MARK: - private
    
    internal func create( callback:OnInitializedCallback) -> RemonConferenceMasterCallbacks {
        let master = RemonParticipant()
        self.set(index: 0, channelName: "", client: master)
        callback(master)
        
        master.videoCodec = "VP8"
        
        
        master.onCreate { [weak self] name in
            print("[RemonConference] master participant onCreate")
            self?.masterCallback?.createCallback?(name)
            self?.setMasterChannelName(name: name!)
            self?.fetchChannels()
        }
    
        master.onClose {[weak self]_ in
            print("[RemonConference] master participant onClose" )
            self?.remove(index: 0)
            self?.masterCallback?.closeCallback?()
            self?.masterCallback = nil
            
            
            self?.closeAll()
        }
    
        master.onError { [weak self] err in
            print("[RemonConference] master participant onError=\(err.localizedDescription)")
            self?.masterCallback?.errorCallback?(err)
            self?.closeAll()
        }
        
        master.onRoomEvent{ type, channel in
            print("[RemonConference] type=\(type),channel=\(channel)")
            self.onParticipant(type: type, channelName: channel)
        }
        
        masterCallback = RemonConferenceMasterCallbacks()
        return masterCallback!
    }
    
    
    internal func join( roomName:String ) -> RemonConferenceViewer {
        if let item = self.get(index: 0) {
            if let master = item.client {

                // 송출을 위해 room 생성, 이미 있는경우 해당 room에 참여
                self.roomName = roomName
                master.create(name: self.roomName)
            }
        }
        return self
    }
    
    
    func setMasterChannelName( name:String ) {
        conferenceArray[0].name = name
    }
    
    func count() -> Int {
        var count = 0
        for item in conferenceArray {
            if item.client != nil {
                count+=1
            }
        }
        return count
    }

    func get( index:Int) -> RemonSlotItem? {
        if( index > conferenceArray.count ) {
            return nil
        }
        return conferenceArray[index]
    }
    
    func getIndex( name:String ) -> Int {
        locker.lock()
        defer { locker.unlock() }
        
        var index = 0
        for item in conferenceArray {
            if name == item.name {
                return index
            }
            index+=1
        }
        return -1
    }
    
    
    
    func getAvailableIndex( name: String ) -> Int {
        locker.lock()
        defer { locker.unlock() }
        
        for item in conferenceArray {
            if name == item.name {
                return -2
            }
        }
        
        var index:Int = 0
        for item in conferenceArray {
            if (item.name == nil) && (item.client == nil ) {
                return index
            }
            index+=1
        }
        
        return -1
    }
    
    
    func set( index:Int, channelName:String, client:RemonParticipant ) {
        if( index > conferenceArray.count ) {
            return
        }
        
        locker.lock()
        defer { locker.unlock() }
        
        conferenceArray[index].name = channelName
        conferenceArray[index].client = client
    }
    
    func remove( index: Int ) {
        if( index > conferenceArray.count ) {
            return
        }
        
        locker.lock()
        defer { locker.unlock() }
        
        print("[RemonConference] remove index=\(index)")
        conferenceArray[index].name = nil
        conferenceArray[index].client = nil
        
    }
    
    func closeAll() {
        for i in 0..<conferenceArray.count {
            if let client = conferenceArray[i].client {
                print("[RemonConference.closeAll] close index=\(i)")
                client.closeRemon()
            }
        }
    }
    
    func fetchChannels() {
        guard let masterClient = self.get(index: 0)?.client  else {
            
            return
        }
        
        masterClient.fetchChannels(roomName: self.roomName, complete: { [weak self] list in
            guard let channelList = list else {
                return
            }
            
            for item in channelList {
                self?.onParticipant(type: "join", channelName: item.chId)
            }
        })
    }
    
    func onParticipant( type:String, channelName:String ) {
        print("[RemonConference] onParticipant:type=\(type),channelName=\(channelName)")
        if type == "leave" {
            let index = self.getIndex(name: channelName)
            print("[RemonConference] leave index=\(index)")
            
            if index > 0 {
                let item = self.get(index: index)
                if item?.client?.getCurrentRemonState() != RemonState.CLOSE.rawValue {
                    item?.client?.closeRemon()
                } else {
                    self.remove(index: index)
                }
            }
        } else if type == "join" {
            print("[RemonConference] *********************************" )
            guard let masterClient = self.get(index: 0)?.client  else {
                print("[RemonConference] master client is not available")
                return
            }
            
    
            let index:Int = self.getAvailableIndex(name: channelName)
            print("[RemonConference] get available index=\(index)")
            if index <= 0 {
                print("[RemonConference] this participant already added")
                return
            }

            let client = RemonParticipant()
            
            client.restUrl = masterClient.restUrl
            client.wsUrl = masterClient.wsUrl
            client.logUrl = masterClient.logUrl
            client.serviceId = masterClient.serviceId
            client.serviceKey = masterClient.serviceKey
            client.serviceToken = masterClient.serviceToken
            client.videoCodec = masterClient.videoCodec
            
            self.userJoinedCallback?( channelName, index, client)
            
            client.onJoin { [weak self, index] channelName in
                print("[RemonConference] participant \(index) onJoin")
                self?.userCallback?.joinCallback?(channelName)
            }
            
            client.onClose { [weak self, index] _ in
                print("[RemonConference] participant \(index) onClose")
                self?.remove(index: index)
                self?.userCallback?.closeCallback?()
                
                if self?.count() == 0 {
                    self?.userCallback = nil
                }
            }
            
            client.onError { [weak self, index] err in
                print("[RemonConference] participant \(index) onError:\(err.localizedDescription)")
                self?.userCallback?.errorCallback?(err)
            }
            
            self.set(index: index, channelName: channelName, client: client)
            
            DispatchQueue.main.async { [channelName] in
                print("[RemonConference] participant \(index) try to join");
                client.join(chId: channelName)
            }
        }
    }
}
