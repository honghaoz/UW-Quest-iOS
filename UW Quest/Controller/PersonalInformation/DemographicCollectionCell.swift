//
//  DemographicCollectionCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-01.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class DemographicCollectionCell: TitleSubTitleCollectionViewCell {
    func configCitizenship(demograohicInfo: PersonalInformation.DemographicInformation) {
        var mainTitle: String = "Citizenship Information"
        var tuples: [(String, String)] = []
        for each in demograohicInfo.citizenshipInformations! {
            let newTuple = (each.country, each.description)
            tuples.append(newTuple)
        }
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
    
    func configDemographicInformation(demograohicInfo: PersonalInformation.DemographicInformation) {
        var mainTitle: String = "Demographic Information"
        var tuples: [(String, String)] = [
            ("ID", demograohicInfo.demographicInfo!.id),
            ("Gender", demograohicInfo.demographicInfo!.gender),
            ("Date of Birth", demograohicInfo.demographicInfo!.dateOfBirth),
            ("Marital Status", demograohicInfo.demographicInfo!.maritalStatus)
        ]
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
    
    func configNationalIds(demograohicInfo: PersonalInformation.DemographicInformation, index: Int) {
        // Index must be valid
        var mainTitle: String = "National Identification Number"
        var nationalId = demograohicInfo.nationalIdNumbers![index]
        var tuples: [(String, String)] = [
            ("Country", nationalId.country),
            ("National ID Type", nationalId.nationalIdType),
            ("National ID", nationalId.nationalId)
        ]
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
    
    func configVisa(demograohicInfo: PersonalInformation.DemographicInformation) {
        var mainTitle: String = "Visa or Permit Data"
        var tuples: [(String, String)] = [
            ("Country", demograohicInfo.visaOrPermitData!.country),
            ("Type", demograohicInfo.visaOrPermitData!.type)
        ]
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
}
