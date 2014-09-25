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
        println("typeLabel: \(typeLabel.frame)")
        println("addressLabel: \(addressLabel.frame)")
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        logMethod()
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        logMethod()
        println("typeLabel: \(typeLabel.frame)")
        println("addressLabel: \(addressLabel.frame)")
        println("asdhakjdhkjashdjkashdjkasdasdkjhasdkjhaskjdhkajshd")
//        println("bounds: \(self.bounds)")
//        println("contentView.bounds: \(self.contentView.bounds)")
        addressLabel.preferredMaxLayoutWidth = self.contentView.bounds.width - 2 * kLabelHorizontalInsets
        println("typeLabel: \(typeLabel.frame)")
        println("addressLabel: \(addressLabel.frame)")
//        self.contentView.bounds = self.bounds
    }
    
}