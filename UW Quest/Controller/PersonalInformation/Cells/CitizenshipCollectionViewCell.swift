//
//  CitizenshipCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-01.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class CitizenshipCollectionViewCell: TitleSubTitleCollectionViewCell {
    func configPastDoc(citizenship: PersonalInformation.CitizenshipImmigrationDocument) {
        var docs = citizenship.pastDocumentation
        self.config("Past Documentation", docs: docs)
    }
    
    func configRequiredDoc(citizenship: PersonalInformation.CitizenshipImmigrationDocument) {
        var docs = citizenship.requiredDocumentation
        self.config("Required Documentation", docs: docs)
    }
    
    private func config(mainTitle: String, docs: [PersonalInformation.CitizenshipImmigrationDocument.visaDocument]) {
        var tuples: [(String, String)] = []
        let count = docs.count
        for i in 0 ..< count {
            let eachDoc = docs[i]
            // For more than two lines, add an empty row
            if i > 0 {
                tuples += [(" ", " ")]
            }
            tuples += [("Country", eachDoc.country)]
            tuples += [("Visa Type", eachDoc.visaType)]
            if eachDoc.dateReceived != nil {
                tuples += [("Date Received", eachDoc.dateReceived!)]
            }
            if eachDoc.expirationDate != nil {
                tuples += [("Expiration Date", eachDoc.expirationDate!)]
            }
        }
        self.config(title: mainTitle, subLabelTuples: tuples)
    }
}