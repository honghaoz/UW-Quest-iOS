//
//  EmailCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-29.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

let subTitleColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
let subContentColor: UIColor = subTitleColor
let subTitleFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 15)
let subContentFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14)
let subContentEmptyFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16)

class EmailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    var kTitleLabelMaxWidth: CGFloat!
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    var emailLabelTuples: [(UILabel, UILabel)]!
    
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
        
        emailLabelTuples = []
    }
    
    func createASubTitleLabel() -> UILabel {
        var label = UILabel.newAutoLayoutView()
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.Left
        label.font = subTitleFont
        label.textColor = subTitleColor
        self.contentView.addSubview(label)
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
            label.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
            label.autoSetContentHuggingPriorityForAxis(ALAxis.Horizontal)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: self.kLabelHorizontalInsets)
        })
        return label
    }

    func createASubContentLabel(verticalHuggingPriority: UILayoutPriority) -> UILabel {
        var label = UILabel.newAutoLayoutView()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 100 // Need to change
        label.textAlignment = NSTextAlignment.Right
        label.font = subContentFont
        label.textColor = subContentColor
        self.contentView.addSubview(label)
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: self.kLabelHorizontalInsets)
        })
        UIView.autoSetPriority(verticalHuggingPriority, forConstraints: { () -> Void in
            label.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
        })
        return label
    }
    
    func createEmptyLabel() -> UILabel {
        var label = UILabel.newAutoLayoutView()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 100 // Need to change
        label.textAlignment = NSTextAlignment.Center
        label.font = subContentEmptyFont
        label.textColor = subContentColor
        self.contentView.addSubview(label)
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: self.kLabelHorizontalInsets)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: self.kLabelHorizontalInsets)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: self.kLabelHorizontalInsets)
        })
        return label
    }
    
    func config(title: String, emails: [(String, String)]) {
        // Remove all subviews
        for eachSubview in self.contentView.subviews {
            if eachSubview.isEqual(self.mainTitleLabel) {
                continue
            }
            eachSubview.removeFromSuperview()
        }
        
        self.mainTitleLabel.text = title
        
        // Add emails' labels
        let emailsCount = emails.count
        
        emailLabelTuples.removeAll(keepCapacity: false)
        
        // No emails
        if emailsCount == 0 {
            var emptyLabel: UILabel = self.createEmptyLabel()
            UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                emptyLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.mainTitleLabel, withOffset: self.kLabelVerticalInsets)
                return
            })
            return
        }
        
        var previousSubContentLabel: UILabel!
        
        // There are emails
        for i in 0 ..< emailsCount {
            var subTitleLabel: UILabel = self.createASubTitleLabel()
            subTitleLabel.text = emails[i].0
            
            var subContentLabel: UILabel!
            // Last label
            if i == emailsCount - 1 {
                subContentLabel = self.createASubContentLabel(998)
                UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                    subContentLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: self.kLabelVerticalInsets)
                    return
                })
            } else {
                // Normal label
                subContentLabel = self.createASubContentLabel(999)
            }
            
            subContentLabel.text = emails[i].1
            UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                subTitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: subContentLabel, withOffset: 0)
                subTitleLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: subContentLabel, withOffset: -self.kLabelHorizontalInsets)
            })
            
            // For first one label
            if i == 0 {
                UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                    subTitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: self.mainTitleLabel, withOffset: self.kLabelVerticalInsets)
                    return
                })
            } else {// For other label
                UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                    subTitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: previousSubContentLabel, withOffset: self.kLabelVerticalInsets)
                    return
                })
            }
            previousSubContentLabel = subContentLabel
            let newTuple = (subTitleLabel, subContentLabel!)
            emailLabelTuples.append(newTuple)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for eachTuple in emailLabelTuples {
            var subTitleLabel = eachTuple.0
            var subContentLabel = eachTuple.1
            let widthOfTitle = subTitleLabel.exactSize().width
            subContentLabel.preferredMaxLayoutWidth = self.bounds.width - 3 * kLabelHorizontalInsets - widthOfTitle
        }
    }
}
