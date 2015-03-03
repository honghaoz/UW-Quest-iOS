//
//  CourseHeaderCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 3/1/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class CourseHeaderCell: UICollectionViewCell {

    @IBOutlet weak var courseNumberLabel: UILabel!
    @IBOutlet weak var enrollStateLabel: UILabel!
    @IBOutlet weak var courseNameLabel: ZHAutoLinesLabel!
    
    @IBOutlet weak var unitValueLabel: UILabel!
    @IBOutlet weak var gradeValueLabel: UILabel!
    @IBOutlet weak var gradingValueLabel: UILabel!
    
    override func layoutSubviews() {
        self.contentView.roundCorners(UIRectCorner.TopLeft | .TopRight, radius: 4.0)
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UQCellBackgroundColor
    }
}
