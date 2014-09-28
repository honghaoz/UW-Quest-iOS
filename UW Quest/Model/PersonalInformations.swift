//
//  PersonalInformations.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

enum PersonalInformationType: String {
    case Addresses = "Addresses"
    case Names = "Names"
    case PhoneNumbers = "Phone Numbers"
    case EmailAddresses = "Email Addresses"
    case EmergencyContacts = "Emergency Contacts"
    case DemographicInformation = "Demographic Information"
    case CitizenshipImmigrationDocuments = "Citizenship/Immigration Documents"
    
    static let allValues = [Addresses.toRaw(), Names.toRaw(), PhoneNumbers.toRaw(), EmailAddresses.toRaw(), EmergencyContacts.toRaw(), DemographicInformation.toRaw(), CitizenshipImmigrationDocuments.toRaw()]
}

class PersonalInformation {
    
    let categories: [String]!
    var addresses: [Address]?
    
    init() {
        println("PersonalInformation inited")
        categories = PersonalInformationType.allValues
    }
    
    class Address {
        // Keys
        class func kAddress() -> String {return "address"}
        class func kAddressType() -> String {return "address_type"}
        class func newAddress(rawDict: Dictionary<String, String>) -> Address? {
            if let address: String = rawDict[Address.kAddress()] {
                if let addressType: String = rawDict[Address.kAddressType()] {
                    return Address(address: address, type: addressType)
                }
            }
            return nil
        }
        
        var address: String
        var type: String
        init(address: String, type: String) {
            self.address = address
            self.type = type
        }
    }
    
    /**
    Use raw data from json to init addresses
    
    :param: rawData data object from json, either array or dictionary
    
    :returns: true if successfully inited
    */
    func initAddresses(rawData: AnyObject) -> Bool {
        // Passed in a dictionary
        if let dataDict = rawData as? Dictionary<String, String> {
            if let newAddress: Address = Address.newAddress(dataDict) {
                self.addresses = [newAddress]
                return true
            }
            return false
        }
        
        // Passed in an array of dictionary
        if let dataArray = rawData as? [Dictionary<String, String>] {
            var tempAddresses = [Address]()
            for eachDataDict in dataArray {
                if let newAddress: Address = Address.newAddress(eachDataDict) {
                    tempAddresses.append(newAddress)
                } else {
                    // Some error happens
                    self.addresses = nil
                    return false
                }
            }
            // If goes here, no error happens
            self.addresses = tempAddresses
            return true
        }
        // Invalid type
        return false
    }
    
//    class Name {
//        var firstName: String
//        var lastName: String
//        var middleName: String
//        var namePrefix: String
//        var nameSuffix: String
//        var nameType: String
//        
//        init(firstName: String, lastName: String, middleName: String, namePrefix: String, nameSuffix: String, nameType: String) {
//            self.firstName = firstName
//            self.lastName = lastName
//            self.middleName = middleName
//            self.namePrefix = namePrefix
//            self.nameSuffix = nameSuffix
//            self.nameType = nameType
//        }
//    }
//    
//    class PhoneNumber {
//        var country: String
//        var ext: String
//        var type: String
//        var isPreferred: Bool
//        var telephone: String
//        
//        init (country: String, ext: String, type: String, isPreferred: Bool, telephone: String) {
//            self.country = country
//            self.ext = ext
//            self.type = type
//            self.isPreferred = isPreferred
//            self.telephone = telephone
//        }
//    }
//    
//    class EmergencyContact {
//        var contactName: String
//        var country: String
//        var ext: String
//        var phone: String
//        var isPrimary: Bool
//        var relationship: String
//        
//        init (contactName: String, country: String, ext: String, phone: String, isPrimary: Bool, relationship: String) {
//            self.contactName = contactName
//            self.country = country
//            self.ext = ext
//            self.phone = phone
//            self.isPrimary = isPrimary
//            self.relationship = relationship
//        }
//    }
//    
//    // TODO:
//    
//    class CitizenshipImmigrationDocument {
//        var country: String
//        var dateReceived: String
//        var expirationDate: String
//        var visaType: String
//        
//        init (country: String, dateReceived: String, expirationDate: String, visaType: String) {
//            self.country = country
//            self.dateReceived = dateReceived
//            self.expirationDate = expirationDate
//            self.visaType = visaType
//        }
//    }
    
}

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