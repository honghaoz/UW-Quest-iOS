//
//  CourseComponentCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

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
        
        // Schedule TableCollectionView
        let tableLayout = TableCollectionViewLayout()
        tableLayout.titleFont = titleFont
        tableLayout.contentFont = contentFont
        scheduleCollectionView = TableCollectionView(frame: CGRectZero, collectionViewLayout: tableLayout)
        scheduleCollectionView.tableLayoutDataSource = self
        scheduleCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["scheduleCollectionView"] = scheduleCollectionView
        self.contentView.addSubview(scheduleCollectionView)
        
        metrics["scheduleCollectionViewHeight"] = 100//tableLayout.collectionViewContentSize().height
        
        // Constraints
        componentTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 8)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[componentTitleLabel]-5-[componentContentLabel][v1][sectionTitleLabel]-5-[sectionContentLabel][v2(==v1)][classTitleLabel]-5-[classContentLabel]-8-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[scheduleCollectionView]-8-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[componentTitleLabel]-4-[scheduleCollectionView(scheduleCollectionViewHeight)]-8-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
}

extension CourseComponentCell: TableLayoutDataSource {
    func numberOfColumnsInCollectionView(collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, titleForColumn column: Int) -> String {
        switch column {
        case 0:
            return "Days & Times"
        case 1:
            return "Room"
        case 2:
            return "Instructor"
        case 3:
            return "Start/End Date"
        default:
            assertionFailure("")
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, contentForColumn column: Int, row: Int) -> String {
        
        switch column {
        case 0:
            switch row {
            case 0:
                return "1"
            case 1:
                return "2"
            case 2:
                return "3"
            default:
                assertionFailure("")
            }
        case 1:
            return "DC 1351"
        case 2:
            return "Carey Bissonnette"
        default:
            return "01/07/2015"
        }
    }
}