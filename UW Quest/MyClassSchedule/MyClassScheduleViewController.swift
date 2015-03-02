//
//  MyClassScheduleViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class MyClassScheduleViewController: BaseRootViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let kCellIdentifier: String = "TermCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MyClassScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableView() {
        tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        tableView.backgroundColor = UQBackgroundColor
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! TermTableViewCell
        // Configuration
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // When user tap on the row, show member details, don't deselect this pack, only change selection states through plus button accessory view
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
    }
}