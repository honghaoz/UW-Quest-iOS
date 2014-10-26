//
//  MenuViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let backgroundColor = UIColor(red:0.16, green:0.2, blue:0.24, alpha:1)
    let titleColor = UIColor(red:0.31, green:0.34, blue:0.36, alpha:1)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.backgroundColor = backgroundColor
        self.tableView.backgroundColor = backgroundColor
        self.tableView.separatorStyle = .None
        usernameLabel.text = Locator.sharedLocator.user.username
        usernameLabel.textColor = titleColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
}
