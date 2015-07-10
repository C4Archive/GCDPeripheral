//
//  ViewController.swift
//  GCDPeripheral
//
//  Created by travis on 2015-07-09.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit
import C4Core
import C4UI

public class ViewController: C4CanvasController {
    public var label = UILabel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        label.frame = view.frame
        label.text = "-"
        view.addSubview(label)
        
        canvas.addTapGestureRecognizer { (location, state) -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("tapped", object: self, userInfo: ["location":"\(location.x)|\(location.y)"])
        }
    }
    
}


