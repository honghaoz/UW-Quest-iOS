//
//  UQCollectionReusableView.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class UQCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    
    var indexPath: NSIndexPath!
    
    override func awakeFromNib() {
        self.backgroundColor = UQCellBackgroundColor
    }
}
