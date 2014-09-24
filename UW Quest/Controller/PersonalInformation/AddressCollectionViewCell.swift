//
//  AddressCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 9/22/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
//    override init() {
//        super.init()
//        self.setup()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.setup()
//    }
//    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
//        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        logMethod(logMessage: "Cell Frame: \(self.frame)")
////        self.layer.borderColor = white
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = kBorderCornerRadius
//        self.layer.borderWidth = kBorderWidth
    }
//
//    override func layoutSubviews() {
//        addressLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.addressLabel.frame)
//    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        logMethod(logMessage: "asdhaskjdhjkashdkjashdkjhasdkjaskdjhaskjdhakjsdh")
    }
}