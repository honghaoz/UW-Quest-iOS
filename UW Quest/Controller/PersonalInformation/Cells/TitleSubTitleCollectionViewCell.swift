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
    let mainTitleFont: UIFont = UIFont.helveticaNenueFont(16)
    
    let subTitleColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let subContentColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    
    let subTitleFont: UIFont = UIFont.helveticaNeueLightFont(15)
    let subContentFont: UIFont = UIFont.helveticaNeueLightFont(14)
    
    let subContentEmptyColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let subContentEmptyFont: UIFont = UIFont.helveticaNeueLightFont(16)
    
    var subTitleLabelMaxWidth: CGFloat = 0.0
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    // MARK:
    var mainTitleLabel: ZHAutoLinesLabel?
    var subLabelTuples: [(ZHAutoLinesLabel, ZHAutoLinesLabel)]!
    var emptyLabel: ZHAutoLinesLabel?
    
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
    Config labels
    
    :param: title          Title text for main title, if nil or empty, main title label will not show
    :param: subLabelTuples Array of tuples of sub labels, 0: sub title text, 1: sub content text
    :param: emptyStatement If there is no subLabelTuples, show an empty cell with emptyStatement
    */
    func config(title: String? = nil, subLabelTuples: [(String, String)], emptyStatement: String? = "No Content") {
        // Remove all subviews (will remove all constraints)
        self.contentView.removeAllSubviews()
        
        // For the first sub title label, the previous one should be mainTitleLabel or top of superView
        var previousView: UIView = self.contentView
        
        // If title is not nil or empty, don't show title label
        if (title != nil) && !(title!.isEmpty) {
            self.mainTitleLabel = self.createMainTitleLabel()
            self.mainTitleLabel!.text = title
            previousView = self.mainTitleLabel!
        }
        
        // Add sub labels
        self.subLabelTuples.removeAll(keepCapacity: false)
        let subLabelsCount = subLabelTuples.count
        
        // No sub labels
        if subLabelsCount == 0 {
            var emptyLabel: UILabel = self.createEmptyLabel()
            emptyLabel.text = emptyStatement
            if previousView == self.contentView {
                emptyLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: kLabelVerticalInsets)
            } else {
                emptyLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: previousView, withOffset: kLabelVerticalInsets)
            }
            return
        }
        
        // There are sub labels
        for i in 0 ..< subLabelsCount {
            var subTitleLabel: ZHAutoLinesLabel = self.createASubTitleLabel()
            subTitleLabel.text = subLabelTuples[i].0
            
            var subContentLabel = self.createASubContentLabel()
            subContentLabel.text = subLabelTuples[i].1
            // Last label, add extra contraint for bottom and change vertical hugging priority
            if i == subLabelsCount - 1 {
                subContentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: kLabelVerticalInsets)
            }
            
            if previousView == self.contentView {
                subTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: kLabelVerticalInsets)
            } else {
                subTitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: previousView, withOffset: kLabelVerticalInsets)
            }
            
            subTitleLabel.autoPinEdge(.Top, toEdge: .Top, ofView: subContentLabel, withOffset: 0)
            subTitleLabel.autoPinEdge(.Right, toEdge: .Left, ofView: subContentLabel, withOffset: -kLabelHorizontalInsets)
            
            previousView = subContentLabel
            let newTuple = (subTitleLabel, subContentLabel)
            self.subLabelTuples.append(newTuple)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

//MARK: Helpers
extension TitleSubTitleCollectionViewCell {
    /**
    Create a new main titleLabel, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new main title label
    */
    func createMainTitleLabel() -> ZHAutoLinesLabel {
        var label = ZHAutoLinesLabel.newAutoLayoutView()
        label.numberOfLines = 1
        label.textAlignment = .Left
        label.font = mainTitleFont
        label.textColor = mainTitleColor
        
        self.contentView.addSubview(label)
        label.autoSetContentCompressionResistanceRequired()
        label.autoSetContentHuggingResistanceRequiredForAixs(.Vertical)
        label.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, 0, kLabelHorizontalInsets), excludingEdge: .Bottom)
        
        return label
    }
    
    /**
    Create a new empty content Label, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub empty content label
    */
    func createEmptyLabel() -> ZHAutoLinesLabel {
        var label = ZHAutoLinesLabel.newAutoLayoutView()
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = subContentEmptyFont
        label.textColor = subContentColor
        self.contentView.addSubview(label)
        label.autoSetContentCompressionHuggingResistanceRequired()
        label.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(0, kLabelHorizontalInsets, kLabelHorizontalInsets, kLabelHorizontalInsets), excludingEdge: .Top)
        return label
    }
    
    /**
    Create a new sub titleLabel, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub title label
    */
    func createASubTitleLabel() -> ZHAutoLinesLabel {
        var label = ZHAutoLinesLabel.newAutoLayoutView()
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.Left
        label.font = subTitleFont
        label.textColor = subTitleColor
        self.contentView.addSubview(label)
        label.autoSetContentCompressionHuggingResistanceRequired()
        label.autoPinEdgeToSuperviewEdge(.Left, withInset: kLabelHorizontalInsets)
        return label
    }
    
    /**
    Create a new sub content Label, this label will be added to contentView automatically along with some necessary constraints
    
    :returns: new sub content label
    */
    func createASubContentLabel() -> ZHAutoLinesLabel {
        var label = ZHAutoLinesLabel.newAutoLayoutView()
        label.numberOfLines = 0
        label.textAlignment = .Right
        label.font = subContentFont
        label.textColor = subContentColor
        self.contentView.addSubview(label)
        label.autoSetContentCompressionHuggingResistanceRequired()
        label.autoPinEdgeToSuperviewEdge(.Right, withInset: kLabelHorizontalInsets)
        return label
    }
}
