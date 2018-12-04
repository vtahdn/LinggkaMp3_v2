//
//  Song.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import Foundation
import UIKit

class Song {
    
    var id = ""
    var title = ""
    var artist = ""
    var thumbnail = UIImage()
    var sourceOnline = ""
    var sourceLocal = ""
    var localThumbnail = ""
    var lyric = ""
    
    init(){}
    
    init(_ id: String,_ lyric: String,_ title: String,_ artist: String,_ thumbnail: String,_ source: String){
        
        self.id = id
        self.lyric = lyric
        self.title = title
        self.artist = artist
        let dataImage = try? Data(contentsOf: URL(string: thumbnail)!)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceOnline = source
    }
    
    init(title: String, artist: String, localThumbnail: String, localSource: String) {
        self.title = title
        self.artist = artist
        self.localThumbnail = localThumbnail
        let dataImage = NSData(contentsOfFile: localThumbnail)
        self.thumbnail = UIImage(data: dataImage! as Data)!
        self.sourceLocal = localSource
    }
    
}
