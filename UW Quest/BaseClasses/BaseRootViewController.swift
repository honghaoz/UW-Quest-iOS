//
//  BaseRootViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class BaseRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup menu button
        let menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "Hamburger"), style: UIBarButtonItemStyle.Plain, target: self, action: "menuButtonTapped:")
        self.navigationItem.setLeftBarButtonItem(menuBarButtonItem, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupAnimation()
    }
    
    private func setupAnimation() {
        // Default animation
        navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
    }

    // MARK: Actions
    func menuButtonTapped(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
}
