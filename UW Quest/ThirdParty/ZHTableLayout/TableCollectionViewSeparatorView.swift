//
//  TableCollectionViewSeparatorView.swift
//  PageFlowLayout
//
//  Created by Honghao Zhang on 3/1/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class TableCollectionViewSeparatorView: UICollectionReusableView {
    static var separatorColor = UIColor(white: 0.0, alpha: 0.5)
    
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
        self.backgroundColor = TableCollectionViewSeparatorView.separatorColor
    }
}
