//
//  LyricViewController.swift
//  LinggkaMp3_v2
//
//  Created by Viet Asc on 12/4/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit

class LyricViewController: UIViewController {
    
    var lyric = ""
    
    @IBOutlet weak var myTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTextView.text = lyric
        
    }
    
}
