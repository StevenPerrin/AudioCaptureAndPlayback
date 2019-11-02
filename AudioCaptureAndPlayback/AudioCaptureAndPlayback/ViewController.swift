//
//  ViewController.swift
//  AudioCaptureAndPlayback
//
//  Created by Steven Perrin on 11/1/19.
//  Copyright © 2019 Steven Perrin. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    let audioSession = AVAudioSession.sharedInstance()
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    
    
    
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        requestRecordingPermission()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func recordButtonPress(_ sender: UIBarButtonItem) {
        if sender.image == UIImage(named: "record") {
                startRecording()
            } else {
                finishRecording(success: true)
            }
        }
    
    
    @IBAction func playButtonPress(_ sender: Any) {
        if playButton.image == UIImage(named: "play") {
        if let recordingURL = checkForExistingAudio() {
            do {
                player = try AVAudioPlayer(contentsOf: recordingURL)
                player.play()
                playButton.image = UIImage(named: "stop")
                recordButton.isEnabled = false
            } catch {
                print("Error: Could not play audio")
                playButton.image = UIImage(named: "play")
                recordButton.isEnabled = true
            }
        }
    }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
           playButton.image = UIImage(named: "play")
           recordButton.isEnabled = true
       }
       
       func requestRecordingPermission() {
           audioSession.requestRecordPermission() {
               [unowned self] allowed in
               if allowed {
                   self.recordButton.isEnabled = true
                   do {
                       try self.audioSession.setCategory(.playAndRecord, mode: .default)
                       try self.audioSession.setActive(true)
                   } catch {
                       self.alertUser(title: "Recording Error", message: "Application is unable to record audio.")
                   }
               } else {
                   self.alertUser(title: "Recording Forbidden", message: "This app will not be allowed to record audio, and thus will not function properly.")
               }
           }
       }
       
       func startRecording() {
           let audioFileName = "audio.mp4"
           
           let settings = [
               AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
               AVSampleRateKey: 1200,
               AVNumberOfChannelsKey: 2,
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
           ]
           
           let fileManager = FileManager.default
           let documentDirectoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
           let documentDirectoryURL = documentDirectoryPaths[0]
           let audioFileURL = documentDirectoryURL.appendingPathComponent(audioFileName)
           do {
               recorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
               recorder.delegate = self
               self.recordButton.image = UIImage(named: "stop")
               self.playButton.isEnabled = false
               recorder.record()

           } catch {
               finishRecording(success: false)
           }
       }
       
       func finishRecording(success: Bool) {
           
           recorder.stop()
           if success {
               self.recordButton.image = UIImage(named: "record")
               self.playButton.isEnabled = true
               self.alertUser(title: "Recording Saved", message: "Recording has been made successfully.")
           } else {
               self.recordButton.image = UIImage(named: "record")
               self.alertUser(title: "Recording Failed", message: "Recording could not be completed")
           }
       }
       
       func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
           if !flag {
               finishRecording(success: false)
           }
       }
       
       func checkForExistingAudio() -> URL? {
           let fileManager = FileManager.default
           let documentDirectoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
           let documentDirectoryURL = documentDirectoryPaths[0]
           return documentDirectoryURL.appendingPathComponent("audio.mp4")
       }
       
       func alertUser(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
    

}

