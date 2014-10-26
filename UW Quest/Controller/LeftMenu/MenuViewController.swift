//
//  MenuViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    let kCellIdentifier = "Title"
    
    let backgroundColor = UIColor(red:0.16, green:0.2, blue:0.24, alpha:1)
    let titleColor = UIColor(white: 1.0, alpha: 0.7)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        
//        self.usernameLabel.layer.sha
        self.headerView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.footerView.backgroundColor = UIColor.clearColor()
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
    
    // MARK: - TableView data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var titleCell: MenuTitleCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as MenuTitleCell
        switch indexPath.row {
        case 0:
            titleCell.titleLabel.text = "News"
        case 1:
            titleCell.titleLabel.text = "My Academics"
        case 2:
            titleCell.titleLabel.text = "My Class Schedule"
        case 3:
            titleCell.titleLabel.text = "Search for Classes"
        case 4:
            titleCell.titleLabel.text = "Personal Information"
        default:
            assert(false, "Wrong row number")
        }
        return titleCell
    }
}
