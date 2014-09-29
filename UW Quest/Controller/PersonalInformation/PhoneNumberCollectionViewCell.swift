//
//  PhoneNumberCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/28/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class PhoneNumberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countryTitleLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var telephoneTitleLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UILabel!
    @IBOutlet weak var extensionTitleLabel: UILabel!
    @IBOutlet weak var extensionLabel: UILabel!
    
    var kTitleLabelWidth: CGFloat!
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        
        self.kTitleLabelWidth = self.countryTitleLabel.bounds.width
    }
    
    func configWithType(type: String, preferred: Bool, country: String, telephone: String, ext: String) {
        
        self.typeLabel.text = type + (preferred ? " (preferred)" : "")
        self.countryLabel.text = country
        self.telephoneLabel.text = telephone
        self.extensionLabel.text = ext + (ext.isEmpty ? "-" : "")
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let preferredMaxLayoutWidth = self.bounds.width - 3 * kLabelHorizontalInsets - kTitleLabelWidth
        countryLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        telephoneLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        extensionLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }

}
