//
//  PersonalInformations.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

class Address {
    var address: String
    var type: String
    init(address: String, type: String) {
        self.address = address
        self.type = type
    }
}

class Name {
    var firstName: String
    var lastName: String
    var middleName: String
    var namePrefix: String
    var nameSuffix: String
    var nameType: String
    
    init(firstName: String, lastName: String, middleName: String, namePrefix: String, nameSuffix: String, nameType: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.namePrefix = namePrefix
        self.nameSuffix = nameSuffix
        self.nameType = nameType
    }
}

class PhoneNumber {
    var country: String
    var ext: String
    var type: String
    var isPreferred: Bool
    var telephone: String
    
    init (country: String, ext: String, type: String, isPreferred: Bool, telephone: String) {
        self.country = country
        self.ext = ext
        self.type = type
        self.isPreferred = isPreferred
        self.telephone = telephone
    }
}

class EmergencyContact {
    var contactName: String
    var country: String
    var ext: String
    var phone: String
    var isPrimary: Bool
    var relationship: String
    
    init (contactName: String, country: String, ext: String, phone: String, isPrimary: Bool, relationship: String) {
        self.contactName = contactName
        self.country = country
        self.ext = ext
        self.phone = phone
        self.isPrimary = isPrimary
        self.relationship = relationship
    }
}

// TODO:

//class DemographicInformation {
//    var note: String
//    class CitizenshipInformation {
//        var country: String
//        var description: String
//        init(country: String, description: String) {
//            self.country = country
//            self.description = description
//        }
//    }
//    var citizenshipInformations: [CitizenshipInformation]
//    var dateOfBirth: String
//    var gender: String
//    var id: String
//    var maritalStatus: String
//    class NationalIdentificationNumber {
//        var country: String
//        var nationalId: String
//        var nationalIdType: String
//        init(country: String, nationalId: String, nationalIdType: String) {
//            self.country = country
//            self.nationalId = nationalId
//            self.nationalIdType = nationalIdType
//        }
//    }
//    var nationalIdNumber: NationalIdentificationNumber
//    class VisaOrPermitData {
//        var country: String
//        var type: String
//        init(country: String, type: String) {
//            self.country = country
//            self.type = type
//        }
//    }
//    var visaOrPermitData: VisaOrPermitData
//    
//    init(
//}

class CitizenshipImmigrationDocument {
    var country: String
    var dateReceived: String
    var expirationDate: String
    var visaType: String
    
    init (country: String, dateReceived: String, expirationDate: String, visaType: String) {
        self.country = country
        self.dateReceived = dateReceived
        self.expirationDate = expirationDate
        self.visaType = visaType
    }
}