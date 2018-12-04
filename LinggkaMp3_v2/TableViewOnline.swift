//
//  TableViewOnline.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit
import WebKit

let DocumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first

class TableViewOnline: UIViewController, WKNavigationDelegate {
    
    var songList = [Song]()
    var tempList = [Song]()
    var threadCount = [String:Bool]()
    var timerLimit = [String:Int]()
    
    var processing = 0
    var currentThread = 0
    var numberOfThread = 5
    
    var selectedLink = ""
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        getData()
        
    }
    
    // Source: MP3.Zing.Vn 2018
    func getData() -> Void {
        
        let data = try? Data(contentsOf: URL(string: selectedLink)!)
        let doc = TFHpple(htmlData: data!)
        let path = "//ul[@class='fn-list']/li"
        if let elements = doc?.search(withXPathQuery: path) as? [TFHppleElement] {
            for element in elements {
                DispatchQueue.global(qos: .default).async {
                    if let id = element.attributes["data-id"] as? String {
                        let titlePath = "//h3/a"
                        var titleString = ""
                        if let titles = element.search(withXPathQuery: titlePath) as? [TFHppleElement] {
                            titleString = titles[0].content!
                        } else {
                            print("Id: \(id) - titleString is empty.")
                        }
                        // Start: Artist
                        let artistPath = "//h4[@class='title-sd-item txt-info fn-artist']/a"
                        var artistString = ""
                        
                        if let artists = element.search(withXPathQuery: artistPath) as? [TFHppleElement] {
                            var artistCount = 0
                            for artist in artists {
                                if artists.count <= 1 {
                                    artistString = artist.content!
                                } else {
                                    artistString += ", \(artist.content!)"
                                }
                                artistCount += 1
                            }
                        } else {
                            print("id: \(id) - artistString is empty.")
                        }
                        // End: Artist
                        
                        // Start: thumbnail
                        let thumbnailPath = "//img"
                        var thumbnailString = ""
                        
                        if let thumbnails = element.search(withXPathQuery: thumbnailPath) as? [TFHppleElement] {
                            thumbnailString = thumbnails[0].attributes["src"] as! String
                        } else {
                            print("id: \(id) - thumbnailString is empty.")
                        }
                        
                        let song = Song(id, "", titleString, artistString, thumbnailString, "")
                        self.tempList.append(song)
                        self.threadCount[id] = true
                    }
                }
            }
            
            // Initial a timer as a thread to get song links
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerForCount(sender:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerForCount(sender: Timer) -> Void {
        
        // Check threads status
        var threadFinishRuning = true
        
        for element in threadCount {
            if element.value == false {
                threadFinishRuning = false
                print("The thread at \(element.value) is not finished.")
                break
            }
        }
        
        // Initial 4 threads by timers per time to get song links
        
        if threadFinishRuning {
            let size = tempList.count
            for i in currentThread..<size {
                if processing < numberOfThread {
                    initWeb(tempList[i].id)
                    processing += 1
                    currentThread += 1
                } else {
                    break
                }
            }
            if currentThread >= size - 1 {
                sender.invalidate()
            }
        }
        
    }
    
    // Initial WKWebViews to get links by song id.
    func initWeb(_ id: String) -> Void {
        
        let web = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        web.load(URLRequest(url: URL(string: "https://mp3.zing.vn/bai-hat/\(id).html")!))
        web.navigationDelegate = self as WKNavigationDelegate
        web.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.12 (KHTML, like Gecko) Version/11.1 Safari/605.1.12"
        web.backgroundColor = .black
        view.addSubview(web)
        let selector = #selector(updateTimer(sender:))
        let count = Count(count: 0)
        let size = tempList.count
        var div = 2
        for i in 0..<size {
            if tempList[i].id == id {
                div += i
                break
            }
        }
        let index = 1 + 1/Float(div)
        let data = [web, count, id] as [Any]
        _ = Timer.scheduledTimer(timeInterval: TimeInterval(index), target: self, selector: selector, userInfo: data, repeats: true)
        
    }
    
    class Count {
        var count: Int
        init(count: Int) {
            self.count = count
        }
    }
    
    // Get download links and lyrics when are avaiable, update function by timers.
    @objc func updateTimer(sender: Timer) -> Void {
        
        let data = sender.userInfo as! [Any]
        let web = data[0] as! WKWebView
        let count = data[1] as! Count
        let id = data[2] as! String
        var song = Song()
        for s in tempList {
            if s.id == id {
                song = s
                break
            }
        }
        count.count += 1
        if count.count < 60 && song.sourceOnline == "" {
            web.evaluateJavaScript("document.getElementById('tabService').getAttribute('id')") { (value, error) in
                if value != nil {
                    if song.lyric == "" {
                        web.evaluateJavaScript("document.getElementsByClassName('fn-wlyrics')[3].innerText", completionHandler: { (value, error) in
                            if value != nil {
                                song.lyric = value as! String
                            }
                        })
                    }
                    web.evaluateJavaScript("document.getElementsByClassName('fn-128')[2].getAttribute('data-id') == null", completionHandler: { (value, error) in
                        if let close = value as? Bool {
                            if close {
                                web.evaluateJavaScript("document.getElementById('tabService').click()", completionHandler: { (value, error) in
                                })
                            } else {
                                web.evaluateJavaScript("document.getElementsByClassName('z-label')[0].innerText", completionHandler: { (value, error) in
                                    if value as! String == "VIP" {
                                        self.comboWebClose(song, sender, web, id)
                                        let alertMessage = "The \(song.title) is vip. \nDownload link is Unavaiable"
                                        self.downloadAlert(alertMessage)
                                    } else {
                                        web.evaluateJavaScript("document.getElementsByClassName('fn-128')[2].getAttribute('href')", completionHandler: { (value, error) in
                                            if value != nil {
                                                song.sourceOnline = "https:/mp3.zing.vn\(value as! String)"
                                                self.comboWebClose(song, sender, web, id)
                                            }
                                        })
                                    }
                                })
                            }
                        }
                    })
                }
            }
        } else {
            closeWeb(sender, web, id)
        }
        
    }
    
    // Close WKWebView after finishing.
    func closeWeb(_ sender: Timer,_ web: WKWebView,_ id: String) -> Void {
        sender.invalidate()
        web.stopLoading()
        web.removeFromSuperview()
    }
    
    // Combination of the close action.
    func comboWebClose(_ song: Song,_ sender: Timer,_ web: WKWebView,_ id: String) -> Void {
        addSongToList(song)
        closeWeb(sender, web, id)
        processing -= 1
    }
    
    // Add song to the list and update TableView
    func addSongToList(_ song: Song) -> Void {
        
        songList.append(song)
        self.myTableView.reloadData()
        
    }
    
    // Alert For Download Links
    func downloadAlert(_ message: String) -> Void {
        
        let alert = UIAlertController(title: "Get Music Link Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            switch action.style {
            case .default:
                alert.dismiss(animated: true, completion: nil)
                break
            case .cancel:
                print("cancel")
                break
            case .destructive:
                print("destructive")
                break
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // Write Data
    func writeDataToPath(_ data: NSObject, path: String) -> Void {
        
        if let dataToWrite = data as? Data {
            try? dataToWrite.write(to: URL(fileURLWithPath: path), options: [.atomic])
        } else if let dataInfo = data as? NSDictionary {
            dataInfo.write(toFile: path, atomically: true)
        }
        
    }
    
    // Song Info
    func writeInfoSong(_ song: Song, _ path: String) -> Void {
        
        let dictData = NSMutableDictionary()
        dictData.setValue(song.title, forKey: "title")
        dictData.setValue(song.artist, forKey: "artist")
        dictData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dictData.setValue(song.sourceOnline, forKey: "sourceOnline")
        
        // Write Info
        writeDataToPath(dictData, path: "\(path)/info.plist")
        
        // Write thumbnail
        let dataThumbnail = NSData(data: song.thumbnail.pngData()!) as Data
        writeDataToPath(dataThumbnail as NSObject, path: "\(path)/thumbnail.png")
        
    }
    
    // Download songs
    func downloadSong(_ index: Int) -> Void {
        
        let urlString = songList[index].sourceOnline
        let songData = try? Data(contentsOf: URL(string: urlString)!)
        if let dir = DocumentDirectoryPath {
            let pathToWriteSong = "\(dir)/\(songList[index].title)"
            // Writing
            do {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                print(error.localizedDescription)
            }
            // Write songs
            if let data = songData {
                writeDataToPath(data as NSData, path: "\(pathToWriteSong)/\(songList[index].title).mp3")
            } else {
                print("dataSong is nil")
            }
            writeInfoSong(songList[index], pathToWriteSong)
        }
        
    }
    
    // Send a lyric to LyricView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "lyric" {
            let destination = segue.destination as! LyricViewController
            let audioPlay = AudioPlayer.sharedInstance
            destination.lyric = audioPlay.lyric
        }
        
    }
    
}

extension TableViewOnline: UITableViewDelegate {
    
    // Cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
        
    }
    
    // Selected song
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let audioPlay = AudioPlayer.sharedInstance
        let path = songList[indexPath.row].sourceOnline
        if path != "" {
            audioPlay.pathString = songList[indexPath.row].sourceOnline
            audioPlay.titleSong = songList[indexPath.row].title + "(\(songList[indexPath.row].artist))"
            audioPlay.lyric = songList[indexPath.row].lyric
            audioPlay.setupAudio()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserveAudio"), object: nil)
        
    }
    
    // Download Button For Cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Download") { (action, index) in
            DispatchQueue.global().async {
                self.downloadSong(indexPath.row)
            }
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/266, alpha: 1)
        return [edit]
    }
    
}

extension TableViewOnline: UITableViewDataSource {
    
    // Number Of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }
    
    // Data For Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = songList[indexPath.row].thumbnail
        cell.textLabel?.text = songList[indexPath.row].title
        cell.textLabel?.textColor = .white
        return cell
        
    }
    
    
}
