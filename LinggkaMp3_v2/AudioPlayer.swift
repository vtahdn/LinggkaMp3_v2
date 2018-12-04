//
//  AudioPlayer.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import AVFoundation
import UIKit

class AudioPlayer: NSObject {
    
    static let sharedInstance = AudioPlayer()
    
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = "Title"
    var lyric = ""
    var player = AVPlayer()
    
    func setupAudio() -> Void {
        
        if pathString != "" {
            var url: URL
            if let checkingUrl = URL(string: pathString) {
                url = checkingUrl
            } else {
                url = URL(fileURLWithPath: pathString)
            }
            
            player = AVPlayer(url: url)
            player.rate = 1.0
            player.volume = 0.5
            player.play()
            playing = true
            repeating = true
        }
        
    }
    
    func Repeat(_ repeatSong: Bool) -> Void {
        
        if repeatSong == true {
            repeating = true
        } else {
            repeating = false
        }
        
    }
    
    func action_PlayPause() -> Void {
        
        if playing == false {
            player.play()
            playing = true
        } else {
            player.pause()
            playing = false
        }
    }
    
    func sld_Duration(_ value: Float) -> Void {
        
        let timeToSeek = value * duration
        let time = CMTimeMake(value: Int64(timeToSeek), timescale: 1)
        player.seek(to: time)
        
    }
    
    func sld_Volume(_ value: Float) -> Void {
        player.volume = value
    }
    
}
