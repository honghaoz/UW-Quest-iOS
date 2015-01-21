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
    @IBOutlet weak var headerShadownView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    let kCellIdentifier = "Title"
    
    let backgroundColor = UIColor(red:0.16, green:0.2, blue:0.24, alpha:1)
    let titleColor = UIColor(white: 1.0, alpha: 0.7)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = backgroundColor
        
        // Header View
        headerView.backgroundColor = self.view.backgroundColor

        // Add a shadow under segBackgroundView
        headerShadownView.clipsToBounds = false
        headerShadownView.layer.shadowColor = UIColor.blackColor().CGColor
        headerShadownView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        headerShadownView.layer.shadowRadius = 5.0
        headerShadownView.layer.shadowOpacity = 0.3
        
        // Username label
        usernameLabel.clipsToBounds = false
        usernameLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        usernameLabel.layer.shadowRadius = 6.0
        usernameLabel.layer.shadowOffset = CGSizeZero
        usernameLabel.layer.shadowOpacity = 0.8
        usernameLabel.text = Locator.user.username
        usernameLabel.textColor = titleColor
        
        // Table view
        tableView.backgroundColor = UIColor.clearColor()
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0), animated: true, scrollPosition: .Top)
        
        footerView.backgroundColor = self.view.backgroundColor
        
        footerView.clipsToBounds = false
        footerView.layer.shadowColor = UIColor.blackColor().CGColor
        footerView.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        footerView.layer.shadowRadius = 5.0
        footerView.layer.shadowOpacity = 0.15
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    // MARK: - TableView delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 40.0
    }
}
