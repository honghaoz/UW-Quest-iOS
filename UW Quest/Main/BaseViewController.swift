//
//  BaseViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/21/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class BaseViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.userInteractionEnabled = true
        self.navigationBar.translucent = false
    }
}
