//
//  ViewController.swift
//  record
//
//  Created by lhs on 2018. 7. 17..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import AVFoundation

class RViewController: UIViewController {
    
    @IBAction func aewfew(_ sender: Any) {
        self.startRecording()
    }
    
    @IBAction func cfghjkl(_ sender: Any) {
        self.stopRecording()
    }
    // Recording audio to a file:
    var engine = AVAudioEngine()
    var distortion = AVAudioUnitDistortion()
    var reverb = AVAudioUnitReverb()
    var audioBuffer = AVAudioPCMBuffer()
    var outputFile = AVAudioFile()
    var delay = AVAudioUnitDelay()
    var isRealTime = false
    var isReverbOn = false
    
    func URLFor(_ filename: String) -> URL {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsPath.append(contentsOf: filename)
        return URL(fileURLWithPath: documentsPath)
    }
    
    func initializeAudioEngine() {
        engine.stop()
        engine.reset()
        engine = AVAudioEngine()
        
        isRealTime = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            
            let ioBufferDuration = 128.0 / 44100.0
            
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
            
        } catch {
            
            assertionFailure("AVAudioSession setup error: \(error)")
        }
        
        let fileUrl = URLFor("/NewRecording.caf")
        print(fileUrl)
        do {
            try outputFile = AVAudioFile(forWriting: fileUrl, settings: engine.mainMixerNode.outputFormat(forBus: 0).settings)
        }
        catch {
            
        }
        
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        
        //settings for reverb
        reverb.loadFactoryPreset(.mediumChamber)
        reverb.wetDryMix = 40 //0-100 range
        engine.attach(reverb)
        
        delay.delayTime = 0.2 // 0-2 range
        engine.attach(delay)
        
        //settings for distortion
        distortion.loadFactoryPreset(.drumsBitBrush)
        distortion.wetDryMix = 20 //0-100 range
        engine.attach(distortion)
        
        
        engine.connect(input, to: reverb, format: format)
        engine.connect(reverb, to: distortion, format: format)
        engine.connect(distortion, to: delay, format: format)
        engine.connect(delay, to: engine.mainMixerNode, format: format)
        
        assert(engine.inputNode != nil)
        
        isReverbOn = false
        
        try! engine.start()
    }
    
    func startRecording() {
        
        let mixer = engine.mainMixerNode
        let format = mixer.outputFormat(forBus: 0)
        
        mixer.installTap(onBus: 0, bufferSize: 1024, format: format, block:
            { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                
                print(NSString(string: "writing"))
                do {
                    try self.outputFile.write(from: buffer)
                }
                catch {
                    print(NSString(string: "Write failed"));
                }
        })
    }
    
    func stopRecording() {
        
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeAudioEngine()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

