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
//        self.setTranslatesAutoresizingMaskIntoConstraints(false)
//        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        if isIOS7 {
            self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        
        println("typeLabel: \(typeLabel.frame)")
        println("addressLabel: \(addressLabel.frame)")
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
    
    override func updateConstraints() {
        addressLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
        println("set max width: \(addressLabel.preferredMaxLayoutWidth)")
        super.updateConstraints()
//        println("\(addressLabel.constraintsAffectingLayoutForAxis(UILayoutConstraintAxis.Horizontal))")
        println("self constrains: \(self.constraints())")
        println("self.contentView constrains: \(self.constraints())")
//        for eachConstraint in self.constraints() {
//            if eachConstraint.isKindOfClass(NSAutoresizingMaskLayoutConstraint.self) {
//                self.removeConstraint(eachConstraint)
//            }
//        }
        
        autoRemoveConstraintsAffectingView()
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        logMethod()
//        println("typeLabel: \(typeLabel.frame)")
//        println("addressLabel: \(addressLabel.frame)")
//        println("asdhakjdhkjashdjkashdjkasdasdkjhasdkjhaskjdhkajshd")
//        println("bounds: \(self.bounds)")
//        println("contentView.bounds: \(self.contentView.bounds)")
//        addressLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
////        addressLabel.bounds = CGRectMake(0, 0, addressLabel.preferredMaxLayoutWidth, addressLabel.bounds.height)
//        println("typeLabel: \(typeLabel.frame)")
//        println("addressLabel: \(addressLabel.frame)")
////        self.contentView.bounds = self.bounds
//    }
    
}