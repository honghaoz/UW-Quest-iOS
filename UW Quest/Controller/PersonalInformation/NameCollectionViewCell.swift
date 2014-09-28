//
//  NameCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/28/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class NameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var firstNameTitleLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var middleNameTitleLabel: UILabel!
    @IBOutlet weak var middleNameLable: UILabel!
    @IBOutlet weak var lastNameTitleLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var namePrefixTitleLabel: UILabel!
    @IBOutlet weak var namePrefixLabel: UILabel!
    @IBOutlet weak var nameSuffixTitleLabel: UILabel!
    @IBOutlet weak var nameSuffixLabel: UILabel!
    
    var kTitleLabelWidth: CGFloat!
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        if isIOS7 {
            // Need set autoresizingMask to let contentView always occupy this view's bounds
            self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UQCellBackgroundColor
        
        self.kTitleLabelWidth = self.firstNameTitleLabel.bounds.width
    }
    
    func configWithType(type: String, firstName: String, middleName: String, lastName: String, namePrefix: String, nameSuffix: String) {
        self.typeLabel.text = type
        self.firstNameLabel.text = firstName
        self.middleNameLable.text = middleName
        self.lastNameLabel.text = lastName
        self.namePrefixLabel.text = namePrefix
        self.nameSuffixLabel.text = nameSuffix
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let preferredMaxLayoutWidth = self.bounds.width - 3 * kLabelHorizontalInsets - kTitleLabelWidth
        firstNameLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        middleNameLable.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        lastNameLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        namePrefixLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        nameSuffixLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }
}
