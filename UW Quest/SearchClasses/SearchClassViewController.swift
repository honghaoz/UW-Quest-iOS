//
//  SearchClassViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/20/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class SearchClassViewController: BaseRootViewController {
    
    @IBOutlet weak var tableView: ZHDynamicTableView!
    
    let kInstitutionCellIdentifier = "InstitutionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
}

extension SearchClassViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        // Do extra setups
        tableView.backgroundColor = UQBackgroundColor
    }
    
    // Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kInstitutionCellIdentifier) as SearchClassInstitutionCell
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // Delegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = self.tableView.dequeueReusableOffScreenCellWithIdentifier(kInstitutionCellIdentifier) as SearchClassInstitutionCell
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
}
