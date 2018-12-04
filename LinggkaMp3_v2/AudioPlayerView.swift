//
//  AudioPlayerView.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerView: UIViewController, AVAudioPlayerDelegate {
    
    let audioPlayer = AudioPlayer.sharedInstance
    @IBOutlet weak var btn_Play: UIButton!
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var sld_Duration: UISlider!
    @IBOutlet weak var sld_Volume: UISlider!
    @IBOutlet weak var lbl_title: UILabel!
    var checkAddObserverAudio = false
    
    func addThumbImgForButton() {
        
        if audioPlayer.playing == true {
            btn_Play.setBackgroundImage(UIImage(named: "pause.png"), for: UIControl.State())
        } else {
            btn_Play.setBackgroundImage(UIImage(named: "play.png"), for: UIControl.State())
        }
        
    }
    
    @objc func setupObserveAudio() {
        
        lbl_title.text = audioPlayer.titleSong
        addThumbImgForButton()
        if audioPlayer.playing && !checkAddObserverAudio {
            btn_Play.isEnabled = true
            checkAddObserverAudio = true
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.player.currentItem)
        }
        
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        
        if audioPlayer.repeating {
            audioPlayer.player.seek(to: CMTime.zero)
            audioPlayer.player.play()
        }
        
    }
    
    @objc func timeUpdate() {
        
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.value)!)/Float((audioPlayer.player.currentItem?.duration.timescale)!)
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().value)/Float(audioPlayer.player.currentTime().timescale)
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        if audioPlayer.duration > 0 {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sdduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            self.lbl_CurrentTime.text = String(format: "%02d", m) + ":" + String(format: "%02d", s)
            self.lbl_TotalTime.text = String(format: "%02d", mduration) + ":" + String(format: "%02d", sdduration)
            self.sld_Duration.value = Float(audioPlayer.currentTime/audioPlayer.duration)
            self.sld_Volume.value = audioPlayer.player.volume
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_Play.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(setupObserveAudio), name: NSNotification.Name(rawValue: "setupObserveAudio"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupObserveAudio()
        
    }
    
    @IBAction func Repeat(_ sender: UISwitch) {
        
        audioPlayer.Repeat(sender.isOn)
        
    }
    
    @IBAction func action_PlayPause(_ sender: AnyObject) {
        
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
        
    }
    
    @IBAction func sld_Duration(_ sender: UISlider) {
        
        audioPlayer.sld_Duration(sender.value)
        
    }
    
    @IBAction func sld_Volume(_ sender: UISlider) {
        
        audioPlayer.sld_Volume(sender.value)
        
    }
    
}
