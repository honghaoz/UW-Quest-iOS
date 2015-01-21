//
//  DescriptionCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-30.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {

    var descriptionLabel: UILabel!
    
    let textColor = UIColor(white: 0, alpha: 0.7)
    let smallFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 13)!
    let largeFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
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
        if isIOS7 {
            // Need set autoresizingMask to let contentView always occupy this view's bounds
            self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        self.bounds = CGRectMake(0, 0, screenWidth, screenHeight)
        self.contentView.bounds = self.bounds
        
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.descriptionLabel = UILabel.newAutoLayoutView()
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.textColor = textColor
        self.contentView.addSubview(self.descriptionLabel)
        self.descriptionLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(8, 8, 8, 8))
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
