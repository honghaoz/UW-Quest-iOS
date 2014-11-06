//
//  TitleSubTitleCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-30.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class TitleSubTitleCollectionViewCell: UICollectionViewCell {
    // Constants
    let mainTitleColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let mainTitleFont: UIFont = UIFont(name: "HelveticaNeue", size: 16)!
    
    let subTitleColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let subContentColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    
    let subTitleFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 15)!
    let subContentFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
    
    let subContentEmptyColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let subContentEmptyFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
    
    var subTitleLabelMaxWidth: CGFloat = 0.0
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    var mainTitleLabel: UILabel?
    var subLabelTuples: [(UILabel, UILabel)]!
    
    override init() {
        super.init()
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    /**
    Basic appearance set up
    */
    func setup() {
        if isIOS7 {
            // Need set autoresizingMask to let contentView always occupy this view's bounds
            self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }
        // On iOS8, if bounds is zero, autoresizingmask will conflit with other constraints
//        self.bounds = CGRectMake(0, 0, CGFloat(MAXFLOAT), CGFloat(MAXFLOAT))
//        self.contentView.bounds = self.bounds
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UQCellBackgroundColor
        
        subLabelTuples = []
    }
    
    /**
    Create a new main titleLabel, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new main title label
    */
    func createMainTitleLabel() -> UILabel {
        var label = UILabel.newAutoLayoutView()
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.Left
        label.font = mainTitleFont
        label.textColor = mainTitleColor
        self.contentView.addSubview(label)
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            label.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
            label.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: self.kLabelHorizontalInsets)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: self.kLabelHorizontalInsets)
            label.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: self.kLabelVerticalInsets)
        })
        return label
    }
    
    /**
    Create a new sub titleLabel, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub title label
    */
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
    
    /**
    Create a new sub content Label, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub content label
    */
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
    
    /**
    Create a new empty content Label, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub empty content label
    */
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
    
    /**
    Config labels
    
    :param: title          Title text for main title, if nil or empty, main title label will not show
    :param: subLabelTuples Array of tuples of sub labels, 0: sub title text, 1: sub content text
    :param: emptyStatement If there is no subLabelTuples, show an empty cell with emptyStatement
    */
    func config(title: String? = "", subLabelTuples: [(String, String)], emptyStatement: String? = "No Content") {
        // Remove all subviews (will remove all constraints)
        for eachSubview in self.contentView.subviews {
            eachSubview.removeFromSuperview()
        }
        
        // For the first sub title label, the previous one should be mainTitleLabel or top of superView
        var previousView: UIView = self.contentView
        
        // If title is not nil or empty, don't show title label
        if (title != nil) && !(title!.isEmpty) {
            self.mainTitleLabel = self.createMainTitleLabel()
            self.mainTitleLabel!.text = title
            previousView = self.mainTitleLabel!
        }
        
        // Add sub labels
        let subLabelsCount = subLabelTuples.count
        
        self.subLabelTuples.removeAll(keepCapacity: false)
        
        // No sub labels
        if subLabelsCount == 0 {
            var emptyLabel: UILabel = self.createEmptyLabel()
            emptyLabel.text = emptyStatement
            UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                if previousView.isEqual(self.contentView) {
                    emptyLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: self.kLabelVerticalInsets)
                } else {
                    emptyLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: previousView, withOffset: self.kLabelVerticalInsets)
                }
            })
            return
        }
        
        // There are sub labels
        for i in 0 ..< subLabelsCount {
            var subTitleLabel: UILabel = self.createASubTitleLabel()
            subTitleLabel.text = subLabelTuples[i].0
            
            var subContentLabel: UILabel!
            // Last label, add extra contraint for bottom and change vertical hugging priority
            if i == subLabelsCount - 1 {
                subContentLabel = self.createASubContentLabel(998)
                UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                    subContentLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: self.kLabelVerticalInsets)
                    return
                })
            } else {
                // Normal label
                subContentLabel = self.createASubContentLabel(999)
            }
            
            subContentLabel.text = subLabelTuples[i].1
            UIView.autoSetPriority(1000, forConstraints: { () -> Void in
                if previousView.isEqual(self.contentView) {
                    subTitleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: self.kLabelVerticalInsets)
                } else {
                    subTitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: previousView, withOffset: self.kLabelVerticalInsets)
                }
                
                subTitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: subContentLabel, withOffset: 0)
                subTitleLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: subContentLabel, withOffset: -self.kLabelHorizontalInsets)
            })
            
            previousView = subContentLabel
            let newTuple = (subTitleLabel, subContentLabel!)
            self.subLabelTuples.append(newTuple)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    /**
    Key for set preferredMaxLayoutWidth for labels with multiple lines
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set max sub title label width
        for eachTuple in self.subLabelTuples {
            var subTitleLabel = eachTuple.0
            let widthOfTitle = subTitleLabel.exactSize().width
            if widthOfTitle > self.subTitleLabelMaxWidth {
                self.subTitleLabelMaxWidth = widthOfTitle
            }
        }
        
        // Set preferredMaxLayoutWidth for every sub content label
        for eachTuple in self.subLabelTuples {
            var subContentLabel = eachTuple.1
            subContentLabel.preferredMaxLayoutWidth = self.bounds.width - 3 * kLabelHorizontalInsets - self.subTitleLabelMaxWidth
        }
    }
}
