//
//  NameCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 1/1/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class NameCollectionViewCell: TitleSubTitleCollectionViewCell {
    func config(names: [PersonalInformation.Name]) {
        var tuples = [(String, String)]()
        for name in names {
            let newTuple = (name.nameType, name.name)
            tuples.append(newTuple)
        }
        self.config(title: nil, subLabelTuples: tuples)
    }
}
