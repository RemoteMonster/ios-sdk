//
//  VCasterViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit
import RemoteMonster

class SimpleVoiceCast:UIViewController {
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet var remonCast: RemonCast!
    @IBOutlet weak var chLabel: UILabel!
    @IBOutlet weak var iuputGainSlider: UISlider!
    
    @IBAction func changeInputSliderValue(_ sender: UISlider) {
        
    }
    
    var customConfig:RemonConfig?
    
    var audioRecorder: AVAudioRecorder!
    @IBOutlet weak var rcButton: UIButton!
    @IBAction func recording(_ sender: Any) {
        // 앱내 디렉토리 경로를 추출하여 그 하위에 녹음된 파일이 저장될 경로를 soundFilePath로 생성후 URL을 얻는다.
        let ts = Int(Date().timeIntervalSince1970)
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(ts).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            //            audioRecorder.delegate = self
            audioRecorder.record()
            //            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            //            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            //            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        audioRecorder.stop()
    }
    
    @IBAction func createBoardcast(_ sender: Any) {
        //config is nilable
        self.remonCast.create(customConfig)
    }
    
    
    @IBAction func closeRemonManager(_ sender: Any) {
        self.remonCast.closeRemon()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.remonCast.debugMode = true

        self.remonCast.onInit {
            self.createBtn.isEnabled = false
        }
        
        self.remonCast.onCreate { (chid) in
            DispatchQueue.main.async {
                self.closeBtn.isEnabled = true
                self.chLabel.text = chid
            }
            print(AVAudioSession.sharedInstance().currentRoute)
        }
        
        self.remonCast.onClose {
            self.createBtn.isEnabled = true
            self.closeBtn.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.remonCast.closeRemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
