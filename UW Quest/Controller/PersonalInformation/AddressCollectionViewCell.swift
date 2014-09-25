//
//  AddressCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/22/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /**
        Setup up cell's appearance
    */
    func setup() {
        
        self.addressLabel.text = "<NSAutoresizingMaskLayoutConstraint:0x7fd979fcc9f0 h=-&- v=-&- UIView:0x7fd979f90580.midX == UW_Quest.AddressCollectionViewCell:0x7fd979f90010.midX>, <NSAutoresizingMaskLayoutConstraint:0x7fd979fcca50 h=-&- v=-&- UIView:0x7fd979f90580.width == UW_Quest.AddressCollectionViewCell:0x7fd979f90010.width>, <NSAutoresizingMaskLayoutConstraint:0x7fd979fccaa0 h=-&- v=-&- UIView:0x7fd979f90580.midY == UW_Quest.AddressCollectionViewCell:0x7fd979f90010.midY>, <NSAutoresizingMaskLayoutConstraint:0x7fd979fccb10 h=-&- v=-&- UIView:0x7fd979f90580.height == UW_Quest.AddressCollectionViewCe"
        
        if isIOS7 {
            // Need set autoresizingMask to let contentView always occupy this view's bounds
            self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        self.backgroundColor = UIColor.blueColor()
        self.contentView.backgroundColor = UIColor.greenColor()
        logMethod()
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addressLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
    }
    
}