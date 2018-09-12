//
//  ViewController.swift
//  RemonCall
//
//  Created by lhs on 2018. 9. 10..
//  Copyright © 2018년 Remon. All rights reserved.
//

import UIKit
import CallKit
import PushKit
import RemoteMonster

class RemonCallViewController: UIViewController, CXProviderDelegate, PKPushRegistryDelegate {

    let provider = CXProvider(configuration:  CXProviderConfiguration(localizedName: "RemonCall"))
    let update = CXCallUpdate()
    
    @IBOutlet var remonCall: RemonCall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider.setDelegate(self, queue: nil)
        self.voipRegistration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendCall(_ sender: Any) {
        let uuid = UUID()
        
        remonCall.connect(uuid.uuidString)
        remonCall.onConnect { (chid) in
            if let chid = chid {
                let controller = CXCallController()
                let handle = CXHandle(type: .generic, value: chid)
                let startCallAction = CXStartCallAction(call: uuid, handle: handle)
                
                let transaction = CXTransaction(action: startCallAction)
                controller.request(transaction) { (error) in
                    if let error = error {
                        print("send error", error)
                    } else {
//                        서버에_voip_푸쉬_발송_요청 (calleeToken, chid)
                    }
                }
            }
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        print("sender uuid", action.callUUID.uuidString)
        remonCall.connect(action.callUUID.uuidString)
        remonCall.onComplete {
            print("connection Complete")
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("sender uuid", action.callUUID.uuidString)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        remonCall.closeRemon()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("pushRegistry didUpdate")
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        let d = NSData(data: pushCredentials.token)
        print("token is data", d.description)
        print("token is ", token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("pushRegistry didReceiveIncomingPushWith")
        let data = payload.dictionaryPayload
        let aps = (data["aps"] as! [NSString: NSString])
        if let chid = aps["alert"] as? String {
            print("pushRegistry didReceiveIncomingPushWith chId:", chid)
            update.remoteHandle = CXHandle(type: .generic, value: chid)
            provider.reportNewIncomingCall(with: UUID(uuidString: chid)!, update: update, completion: { error in
                
            })
        }
        
    }
    
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
}
