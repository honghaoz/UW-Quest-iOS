//
//  ZHDynamicCollectionView.swift
//  UW Quest
//
//  Created by Honghao on 1/1/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class ZHDynamicCollectionView: UICollectionView {
    // A dictionary of offscreen cells that are used within the sizeForItemAtIndexPath method to handle the size calculations. These are never drawn onscreen. The dictionary is in the format:
    // { NSString *reuseIdentifier : UICollectionViewCell *offscreenCell, ... }
    private var offscreenCells = Dictionary<String, UICollectionViewCell>()
    private var registeredCellNibs = Dictionary<String, UINib>()
    private var registeredCellClasses = Dictionary<String, UICollectionViewCell.Type>()
    
    override func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        super.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
        registeredCellClasses[identifier] = cellClass as UICollectionViewCell.Type!
    }
    
    override func registerNib(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        super.registerNib(nib, forCellWithReuseIdentifier: identifier)
        registeredCellNibs[identifier] = nib
    }
    
    func dequeueReusableOffScreenCellWithReuseIdentifier(identifier: String) -> UICollectionViewCell? {
        var cell: UICollectionViewCell? = offscreenCells[identifier]
        if cell == nil {
            if registeredCellNibs.has(identifier) {
                let cellNib: UINib = registeredCellNibs[identifier]! as UINib
                cell = cellNib.instantiateWithOwner(nil, options: nil)[0] as? UICollectionViewCell
            } else if registeredCellClasses.has(identifier) {
                let cellClass = registeredCellClasses[identifier] as UICollectionViewCell.Type!
                cell = cellClass()
            } else {
                assertionFailure("\(identifier) is not registered in \(self)")
            }
        }
        return cell
    }
}
