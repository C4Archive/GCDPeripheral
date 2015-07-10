//
//  ViewController.swift
//  GCDPeripheral
//
//  Created by travis on 2015-07-09.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {
    public var label = UILabel()

    override public func viewDidLoad() {
        super.viewDidLoad()
        label.frame = view.frame
        label.text = "-"
        view.addSubview(label)
    }

}


