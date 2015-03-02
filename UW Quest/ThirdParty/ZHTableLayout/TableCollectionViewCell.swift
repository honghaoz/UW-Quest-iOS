//
//  TableCollectionViewCell.swift
//  PageFlowLayout
//
//  Created by Honghao Zhang on 3/1/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class TableCollectionViewCell: UICollectionViewCell {
    
    var textLabel: UILabel = UILabel()
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(textLabel)
        self.contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
    }
}
