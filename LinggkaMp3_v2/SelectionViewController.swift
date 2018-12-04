//
//  SelectionViewController.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Send the title of a song collection to the OnlineViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! TableViewOnline
        var songCollectionLink = ""
        switch segue.identifier {
        case "vietnam":
            songCollectionLink = "https://mp3.zing.vn/top100/Nhac-Tre/IWZ9Z088.html"
            break
        case "pop":
            songCollectionLink = "https://mp3.zing.vn/top100/Pop/IWZ9Z097.html"
            break
        case "asia":
            songCollectionLink = "https://mp3.zing.vn/top100/Nhac-Tre/IWZ9Z08W.html"
            break
        case "classic":
            songCollectionLink = "https://mp3.zing.vn/top100/Nhac-Tre/IWZ9Z0BI.html"
            break
        default:
            break
        }
        destination.selectedLink = songCollectionLink
        
    }
    
}
