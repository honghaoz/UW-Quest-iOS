//
//  TableCollectionView.swift
//  PageFlowLayout
//
//  Created by Honghao Zhang on 3/1/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class TableCollectionView: UICollectionView {
    
    weak var tableLayoutDataSource: TableLayoutDataSource!
    
    var kCellIdentifier = "Cell"
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.dataSource = self
        self.registerClass(TableCollectionViewCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
//        scrollIndicatorInsets = UIEdgeInsetsMake(5, 2, -5, -2)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TableCollectionView: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return tableLayoutDataSource.numberOfColumnsInCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableLayoutDataSource.collectionView(collectionView, numberOfRowsInColumn: section) + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as! TableCollectionViewCell
        if indexPath.item == 0 {
            cell.textLabel.font = (self.collectionViewLayout as! TableCollectionViewLayout).titleFont
            cell.textLabel.text = tableLayoutDataSource.collectionView(collectionView, layout: collectionView.collectionViewLayout as! TableCollectionViewLayout, titleForColumn: indexPath.section)
        } else {
            cell.textLabel.font = (self.collectionViewLayout as! TableCollectionViewLayout).contentFont
            cell.textLabel.text = tableLayoutDataSource.collectionView(collectionView, layout: collectionView.collectionViewLayout as! TableCollectionViewLayout, contentForColumn: indexPath.section, row: indexPath.item - 1)
        }
        cell.textLabel.textColor = UIColor(white: 0.0, alpha: 0.5)
        cell.textLabel.textAlignment = .Center
        return cell
    }
}