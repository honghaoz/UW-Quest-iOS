//
//  DescriptionCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-30.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    let smallFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 13)
    let largeFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16)
    
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
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
    }
    
    func configSmall(description: String, textAlignment: NSTextAlignment) {
        self.descriptionLabel.font = self.smallFont
        self.config(description, textAlignment: textAlignment)
    }
    
    func configLarge(description: String, textAlignment: NSTextAlignment) {
        self.descriptionLabel.font = self.largeFont
        self.config(description, textAlignment: textAlignment)
    }
    
    private func config(description: String, textAlignment: NSTextAlignment) {
        self.descriptionLabel.text = description
        self.descriptionLabel.textAlignment = textAlignment
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
    }
}
