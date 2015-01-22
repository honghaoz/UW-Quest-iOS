//
//  ZHDynamicTableView.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/21/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class ZHDynamicTableView: UITableView {
    // A dictionary of offscreen cells that are used within the heightForIndexPath method to handle the size calculations. These are never drawn onscreen. The dictionary is in the format:
    // { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
    private var offscreenCells = Dictionary<String, UITableViewCell>()
    private var registeredCellNibs = Dictionary<String, UINib>()
    private var registeredCellClasses = Dictionary<String, UITableViewCell.Type>()
    
    override func registerClass(cellClass: AnyClass, forCellReuseIdentifier identifier: String) {
        super.registerClass(cellClass, forCellReuseIdentifier: identifier)
        registeredCellClasses[identifier] = (cellClass as? UITableViewCell.Type)!
    }
    
    override func registerNib(nib: UINib, forCellReuseIdentifier identifier: String) {
        super.registerNib(nib, forCellReuseIdentifier: identifier)
        registeredCellNibs[identifier] = nib
    }
    
    /**
    Returns a reusable table view cell object located by its identifier.
    This cell is not showing on screen, it's useful for calculating dynamic cell height
    
    :param: identifier identifier A string identifying the cell object to be reused. This parameter must not be nil.
    
    :returns: UITableViewCell?
    */
    func dequeueReusableOffScreenCellWithIdentifier(identifier: String) -> UITableViewCell? {
        var cell: UITableViewCell? = offscreenCells[identifier]
        if cell == nil {
            cell = self.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
            offscreenCells[identifier] = cell!
        }
        return cell
    }
}
