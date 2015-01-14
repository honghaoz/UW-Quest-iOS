//
//  PhoneNumberCollectionViewCell.swift
//  UW Quest
//
//  Created by Honghao on 1/14/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class PhoneNumberCollectionViewCell: TitleSubTitleCollectionViewCell {
    func config(phoneNumber: PersonalInformation.PhoneNumber) {
        self.configWithType(phoneNumber.type, preferred: phoneNumber.isPreferred, country: phoneNumber.country, telephone: phoneNumber.telephone, ext: phoneNumber.ext)
    }
    
    func configWithType(type: String, preferred: Bool, country: String, telephone: String, ext: String) {
        
        let title = type + (preferred ? " (preferred)" : "")
        
        var tuples = [(String, String)]()
        let countryTuple = ("Country code", country)
        tuples.append(countryTuple)
        
        let telephoneTuple = ("Telephone", telephone)
        tuples.append(telephoneTuple)
        
        let extensionTuple = ("Extension", ext + (ext.isEmpty ? "-" : ""))
        tuples.append(extensionTuple)
        self.config(title: title, subLabelTuples: tuples)
    }
}
