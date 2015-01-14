//
//  EmailCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 1/14/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class EmailCollectionViewCell: TitleSubTitleCollectionViewCell {
    func config(title: String, emails: [(String, String)]) {
        self.config(title: title, subLabelTuples: emails)
    }
}
