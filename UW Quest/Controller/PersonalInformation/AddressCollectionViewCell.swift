//
//  AddressCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/22/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {
    
    var typeLabel: UILabel!
    var addressLabel: UILabel!
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    var didSetupConstraints: Bool = false
    
    override init() {
        logMethod()
        super.init()
        self.setup()
    }
    
    override init(frame: CGRect) {
        logMethod()
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        logMethod()
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        logMethod()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        
        self.typeLabel = UILabel.newAutoLayoutView()
        self.typeLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.typeLabel.numberOfLines = 1
        self.typeLabel.textAlignment = NSTextAlignment.Left
        self.typeLabel.textColor = UQFontGrayColor
        self.typeLabel.backgroundColor = UIColor.redColor()
        
        self.addressLabel = UILabel.newAutoLayoutView()
        self.addressLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.addressLabel.numberOfLines = 0
        self.addressLabel.textAlignment = NSTextAlignment.Left
        self.addressLabel.textColor = UQFontGrayColor
        self.addressLabel.backgroundColor = UIColor.purpleColor()
        
        self.typeLabel.text = "Home"
        self.addressLabel.text = "hakjshdjkh kjh kjh ah kjhjk hkjh kjh kjh kjh kjhkj hkj hakjshkjs h kjh kjh ah kjhjk hkjh kjh kjh kjh kjhh kjh kjh ah kjhjk hkjh kjh kjh kjh kjhh kjh kjh ah kjhjk hkjh kjh kjh kjh kjhh kjh kjh ah kjhjk hkjh kjh kjh kjh kjhh kjh kjh ah kjhjk hkjh kjh kjh kjh kjh"
//        self.addressLabel.text = "h"
        
        self.contentView.addSubview(typeLabel)
        self.contentView.addSubview(addressLabel)
        self.contentView.backgroundColor = UIColor.greenColor()
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
        println("view constrains count: \(self.constraints().count)")
        println("content constrains count: \(self.contentView.constraints().count)")
    }
    
    func setLabelPreferredMaxLayoutWidth(width: CGFloat) {
//        addressLabel.preferredMaxLayoutWidth = width - 2 * kLabelHorizontalInsets
//        self.autoRemoveConstraintsAffectingViewIncludingImplicitConstraints(true)
//        self.autoSetDimension(ALDimension.Height, toSize: 200)
//        self.autoSetDimension(ALDimension.Width, toSize: width)
        println("view constrains count: \(self.constraints().count)")
        println("content constrains count: \(self.contentView.constraints().count)")
    }
    
    override func updateConstraints() {
        logMethod()
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
        if (!self.didSetupConstraints) {
            
            UIView.autoSetPriority(1000) { () -> Void in
                self.typeLabel.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
//                self.typeLabel.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
                
                self.addressLabel.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
//                self.addressLabel.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
                
            }
            
            UIView.autoSetPriority(750) { () -> Void in
                
                
                self.typeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: self.kLabelVerticalInsets)
                self.typeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: self.kLabelHorizontalInsets)
                self.typeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: self.kLabelHorizontalInsets)
                
                
                self.typeLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: self.addressLabel, withOffset: -self.kLabelVerticalInsets)
                
                
                self.addressLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: self.kLabelHorizontalInsets)
                self.addressLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: self.kLabelHorizontalInsets)
                self.addressLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: self.kLabelVerticalInsets)
                
            }

            self.didSetupConstraints = true
        }

        // Must call finally
        super.updateConstraints()
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
        println("view constrains count: \(self.constraints().count)")
        println("content constrains count: \(self.contentView.constraints().count)")
    }

    override func layoutSubviews() {
        logMethod()
        super.layoutSubviews()
        addressLabel.preferredMaxLayoutWidth = self.contentView.bounds.width - 2 * kLabelHorizontalInsets
        println("address bounds: \(addressLabel.frame)")
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
    }
}