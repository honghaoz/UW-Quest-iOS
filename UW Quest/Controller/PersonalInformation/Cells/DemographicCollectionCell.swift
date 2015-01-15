//
//  DemographicCollectionCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-01.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class DemographicCollectionCell: TitleSubTitleCollectionViewCell {
    func config(demograohicInfo: PersonalInformation.DemographicInformation, withKey key: String) {
        var mainTitle: String = key
        var tuples = [(String, String)]()
        for t in (demograohicInfo.dictionary[key]! as [[String]]) {
            let tt = (t[0], t[1])
            tuples.append(tt)
        }
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
}