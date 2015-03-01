//
//  CourseCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class CourseHeaderCell: UICollectionViewCell {
    
}

class CourseComponentCell: UICollectionViewCell {
    let labelColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let titleFont = UIFont.helveticaNeueLightFont(14)
    let contentFont = UIFont.helveticaNenueFont(14)
    
    var componentContentLabel: UILabel!
    var sectionContentLabel: UILabel!
    var classContentLabel: UILabel!
    
    var metrics = [String: CGFloat]()
    var views = [String: UIView]()
    
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
        self.contentView.backgroundColor = UQCellBackgroundColor
        
        // Component
        let componentTitleLabel = UILabel.newAutoLayoutView()
        componentTitleLabel.text = "Component:"
        componentTitleLabel.font = titleFont
        componentTitleLabel.textColor = labelColor
        views["componentTitleLabel"] = componentTitleLabel
        self.contentView.addSubview(componentTitleLabel)
        
        componentContentLabel = UILabel.newAutoLayoutView()
        componentContentLabel.text = "LEC"
        componentContentLabel.font = contentFont
        componentContentLabel.textColor = labelColor
        views["componentContentLabel"] = componentContentLabel
        self.contentView.addSubview(componentContentLabel)
        
        // Section
        let sectionTitleLabel = UILabel.newAutoLayoutView()
        sectionTitleLabel.text = "Section:"
        sectionTitleLabel.font = titleFont
        sectionTitleLabel.textColor = labelColor
        views["sectionTitleLabel"] = sectionTitleLabel
        self.contentView.addSubview(sectionTitleLabel)
        
        sectionContentLabel = UILabel.newAutoLayoutView()
        sectionContentLabel.text = "001"
        sectionContentLabel.font = contentFont
        sectionContentLabel.textColor = labelColor
        views["sectionContentLabel"] = sectionContentLabel
        self.contentView.addSubview(sectionContentLabel)
        
        // Class#
        let classTitleLabel = UILabel.newAutoLayoutView()
        classTitleLabel.text = "Class#:"
        classTitleLabel.font = titleFont
        classTitleLabel.textColor = labelColor
        views["classTitleLabel"] = classTitleLabel
        self.contentView.addSubview(classTitleLabel)
        
        classContentLabel = UILabel.newAutoLayoutView()
        classContentLabel.text = "5711"
        classContentLabel.font = contentFont
        classContentLabel.textColor = labelColor
        views["classContentLabel"] = classContentLabel
        self.contentView.addSubview(classContentLabel)
        
        // Empty view
        let v1 = UIView.newAutoLayoutView()
        views["v1"] = v1
        self.contentView.addSubview(v1)
        
        let v2 = UIView.newAutoLayoutView()
        views["v2"] = v2
        self.contentView.addSubview(v2)
        
        // Constraints
        componentTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
        componentTitleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 8)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[componentTitleLabel]-5-[componentContentLabel][v1][sectionTitleLabel]-5-[sectionContentLabel][v2(==v1)][classTitleLabel]-5-[classContentLabel]-8-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
    }
}
