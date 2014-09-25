//
//  AddressCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/22/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {
    
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
//    override init() {
//        logMethod()
//        super.init()
//        self.setup()
//    }
//    
//    override init(frame: CGRect) {
//        logMethod()
//        super.init(frame: frame)
//        self.setup()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        logMethod()
//        super.init(coder: aDecoder)
//        self.setup()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logMethod()
        setup()
        // Initialization code
    }

    func setup() {
        logMethod()
//        self.setTranslatesAutoresizingMaskIntoConstraints(false)
//        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        logMethod(logMessage: "Cell Frame: \(self.frame)")
        self.layer.borderColor = UQCellBackgroundColor.CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = kBorderCornerRadius
        self.layer.borderWidth = kBorderWidth
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
    }

    override func layoutSubviews() {
        logMethod()
        super.layoutSubviews()
        addressLabel.preferredMaxLayoutWidth = self.contentView.bounds.width - 2 * kLabelHorizontalInsets
        println("view constrains count: \(self.constraints().count)")
        println("content constrains count: \(self.contentView.constraints().count)")
        println("bounds: \(self.bounds)")
        println("contentView.bounds: \(self.contentView.bounds)")
    }
    
}