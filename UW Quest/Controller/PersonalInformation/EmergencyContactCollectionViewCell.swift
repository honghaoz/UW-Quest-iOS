//
//  EmergencyContactCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-30.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class EmergencyContactCollectionViewCell: TitleSubTitleCollectionViewCell {
    func config(emergencyContact: PersonalInformation.EmergencyContact) {
        var mainTitle: String = emergencyContact.contactName + (emergencyContact.isPrimary ? " (primary)" : "")
        var tuples: [(String, String)] = [
            ("Relationship", emergencyContact.relationship),
            ("Country Code", emergencyContact.country),
            ("Phone", emergencyContact.phone),
            ("Extension", emergencyContact.ext)
        ]
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
}