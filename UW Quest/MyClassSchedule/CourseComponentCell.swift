//
//  CourseComponentCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

@objc protocol CourseComponentCellDelegate {
    func numberOfColumnsInCell(cell: CourseComponentCell) -> Int
    func numberOfRowsInColumn(column: Int, cell: CourseComponentCell) -> Int
    func titleForColumn(column: Int, cell: CourseComponentCell) -> String
    func contentForColumn(column: Int, row: Int, cell: CourseComponentCell) -> String
}

class CourseComponentCell: UICollectionViewCell {
    let labelColor: UIColor = UIColor(white: 0.3, alpha: 0.9)
    let titleFont = UIFont.helveticaNeueLightFont(14)
    let contentFont = UIFont.helveticaNenueFont(14)
    
    var componentContentLabel: UILabel!
    var sectionContentLabel: UILabel!
    var classContentLabel: UILabel!
    var scheduleCollectionView: TableCollectionView!
    
    var metrics = [String: CGFloat]()
    var views = [String: UIView]()
    
    var tableLayout: TableCollectionViewLayout!
    var cCollectionViewHeight: NSLayoutConstraint!
    
    weak var delegate: CourseComponentCellDelegate?
    
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
        logDebug()
        self.contentView.backgroundColor = UQCellBackgroundColor
        
//        // Component
//        let componentTitleLabel = UILabel.newAutoLayoutView()
//        componentTitleLabel.text = "Component:"
//        componentTitleLabel.font = titleFont
//        componentTitleLabel.textColor = labelColor
//        views["componentTitleLabel"] = componentTitleLabel
//        self.contentView.addSubview(componentTitleLabel)
//        
//        componentContentLabel = UILabel.newAutoLayoutView()
//        componentContentLabel.text = "LEC"
//        componentContentLabel.font = contentFont
//        componentContentLabel.textColor = labelColor
//        views["componentContentLabel"] = componentContentLabel
//        self.contentView.addSubview(componentContentLabel)
//        
//        // Section
//        let sectionTitleLabel = UILabel.newAutoLayoutView()
//        sectionTitleLabel.text = "Section:"
//        sectionTitleLabel.font = titleFont
//        sectionTitleLabel.textColor = labelColor
//        views["sectionTitleLabel"] = sectionTitleLabel
//        self.contentView.addSubview(sectionTitleLabel)
//        
//        sectionContentLabel = UILabel.newAutoLayoutView()
//        sectionContentLabel.text = "001"
//        sectionContentLabel.font = contentFont
//        sectionContentLabel.textColor = labelColor
//        views["sectionContentLabel"] = sectionContentLabel
//        self.contentView.addSubview(sectionContentLabel)
//        
//        // Class#
//        let classTitleLabel = UILabel.newAutoLayoutView()
//        classTitleLabel.text = "Class#:"
//        classTitleLabel.font = titleFont
//        classTitleLabel.textColor = labelColor
//        views["classTitleLabel"] = classTitleLabel
//        self.contentView.addSubview(classTitleLabel)
//        
//        classContentLabel = UILabel.newAutoLayoutView()
//        classContentLabel.text = "5711"
//        classContentLabel.font = contentFont
//        classContentLabel.textColor = labelColor
//        views["classContentLabel"] = classContentLabel
//        self.contentView.addSubview(classContentLabel)
        
//        // Empty view
//        let v1 = UIView.newAutoLayoutView()
//        views["v1"] = v1
//        self.contentView.addSubview(v1)
//        
//        let v2 = UIView.newAutoLayoutView()
//        views["v2"] = v2
//        self.contentView.addSubview(v2)
        
//        // Schedule TableCollectionView
//        let tableLayout = TableCollectionViewLayout()
//        tableLayout.titleFont = titleFont
//        tableLayout.contentFont = contentFont
//        tableLayout.separatorLineWidth = 0.5
//        scheduleCollectionView = TableCollectionView(frame: CGRectZero, collectionViewLayout: tableLayout)
//        scheduleCollectionView.tableLayoutDataSource = self
//        scheduleCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        views["scheduleCollectionView"] = scheduleCollectionView
//        self.contentView.addSubview(scheduleCollectionView)
//        
//        metrics["scheduleCollectionViewHeight"] = 100//tableLayout.collectionViewContentSize().height
//        
//        // Constraints
//        componentTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
//        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[componentTitleLabel]-5-[componentContentLabel][v1][sectionTitleLabel]-5-[sectionContentLabel][v2(==v1)][classTitleLabel]-5-[classContentLabel]-8-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
//        
//        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[scheduleCollectionView]-8-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
//        
//        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[componentTitleLabel]-4-[scheduleCollectionView(scheduleCollectionViewHeight)]-8-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // Schedule TableCollectionView
        tableLayout = TableCollectionViewLayout()
        tableLayout.titleFont = titleFont
        tableLayout.contentFont = contentFont
        tableLayout.separatorLineWidth = 0.5
        tableLayout.separatorColor = labelColor
        scheduleCollectionView = TableCollectionView(frame: CGRectZero, collectionViewLayout: tableLayout)
        scheduleCollectionView.tableLayoutDataSource = self
        scheduleCollectionView.attachObject(self)
        
        scheduleCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["scheduleCollectionView"] = scheduleCollectionView
        self.contentView.addSubview(scheduleCollectionView)
        
        // Constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[scheduleCollectionView]-8-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[scheduleCollectionView]-5-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        cCollectionViewHeight = NSLayoutConstraint(item: scheduleCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scheduleCollectionView, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: 100)
        scheduleCollectionView.addConstraint(cCollectionViewHeight)
    }
}

extension CourseComponentCell: TableLayoutDataSource {
    func numberOfColumnsInCollectionView(collectionView: UICollectionView) -> Int {
        if self.delegate != nil {
            return self.delegate!.numberOfColumnsInCell(self)
        }
        return 0
        
    }
    func collectionView(collectionView: UICollectionView, numberOfRowsInColumn column: Int) -> Int {
        if self.delegate != nil {
            return self.delegate!.numberOfRowsInColumn(column, cell: self)
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, titleForColumn column: Int) -> String {
        if self.delegate != nil {
            return self.delegate!.titleForColumn(column, cell: self)
        }
        return ""
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, contentForColumn column: Int, row: Int) -> String {
        if self.delegate != nil {
            return self.delegate!.contentForColumn(column, row: row, cell: self)
        }
        return ""
    }
}
