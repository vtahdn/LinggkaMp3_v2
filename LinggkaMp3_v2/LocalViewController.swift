//
//  LocalViewController.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit

class LocalViewController: UIViewController {
    
    var songList = [Song]()
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
        
    }
    
    func getData() -> Void {
        
        songList.removeAll()
        if let dir = DocumentDirectoryPath {
            do {
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders {
                    if folder != ".DS_Store" {
                        let info = NSDictionary(contentsOfFile: dir + "/" + folder + "/" + "info.plist")
                        let title = info!["title"] as! String
                        let artist = info!["artist"] as! String
                        let thumbnailPath = info!["localThumbnail"] as! String
                        let localSource = dir + "/\(title)/\(title).mp3"
                        let localThumbnail = dir + thumbnailPath
                        let currentSong = Song(title: title, artist: artist, localThumbnail: localThumbnail, localSource: localSource)
                        songList.append(currentSong)
                    }
                }
                myTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func removeSong(_ atIndex: Int) -> Void {
        if let dir = DocumentDirectoryPath {
            do {
                let path = dir + "/\(songList[atIndex].title)"
                try FileManager.default.removeItem(atPath: path)
                songList.remove(at: atIndex)
                self.myTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

extension LocalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let audioPlay = AudioPlayer.sharedInstance
        audioPlay.pathString = songList[indexPath.row].sourceLocal
        audioPlay.titleSong = "\(songList[indexPath.row].title) Artist: \(songList[indexPath.row].artist)"
        audioPlay.setupAudio()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setupObserveAudio"), object: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            self.removeSong(indexPath.row)
            self.myTableView.reloadData()
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1)
        return [edit]
        
    }
    
}

extension LocalViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = songList[indexPath.row].thumbnail
        cell.textLabel?.text = songList[indexPath.row].title
        cell.textLabel?.textColor = .white
        return cell
        
    }
    
}
