//
//  CitizenshipCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-01.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class CitizenshipCollectionViewCell: TitleSubTitleCollectionViewCell {
    func config(citizenship: PersonalInformation.CitizenshipImmigrationDocument) {
        var mainTitle: String = "Citizenship/Immigration Documents"
        var tuples: [(String, String)] = [
            ("Country", citizenship.country),
            ("Date Received", citizenship.dateReceived),
            ("Expiration Date", citizenship.expirationDate),
            ("Visa Type", citizenship.visaType)
        ]
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
}
