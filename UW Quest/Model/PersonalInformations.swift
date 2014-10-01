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
    var addresses: [Address]!
    var names: [Name]!
    var phoneNumbers: [PhoneNumber]!
    var emailAddresses: EmailAddress?
    var emergencyContacts: [EmergencyContact]!
    
    init() {
        println("PersonalInformation inited")
        categories = PersonalInformationType.allValues
        addresses = []
        names = []
        phoneNumbers = []
        emergencyContacts = []
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
                    self.addresses = []
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
    
    class Name {
        var firstName: String
        var lastName: String
        var middleName: String
        var namePrefix: String
        var nameSuffix: String
        var nameType: String
        
        class func kFirstName() -> String {return "first_name"}
        class func kLastName() -> String {return "last_name"}
        class func kMiddleName() -> String {return "middle_name"}
        class func kNamePrefix() -> String {return "name_prefix"}
        class func kNameSuffix() -> String {return "name_suffix"}
        class func kNameType() -> String {return "name_type"}
        
        class func newName(rawDict: Dictionary<String, String>) -> Name? {
            let firstName: String? = rawDict[Name.kFirstName()]
            let lastName: String? = rawDict[Name.kLastName()]
            let middleName: String? = rawDict[Name.kMiddleName()]
            let namePrefix: String? = rawDict[Name.kNamePrefix()]
            let nameSuffix: String? = rawDict[Name.kNameSuffix()]
            let nameType: String? = rawDict[Name.kNameType()]
            
            if (firstName != nil) && (lastName != nil) && (middleName != nil) && (namePrefix != nil) && (nameSuffix != nil) && (nameType != nil) {
                return Name(firstName: firstName!, lastName: lastName!, middleName: middleName!, namePrefix: namePrefix!, nameSuffix: nameSuffix!, nameType: nameType!)
            }
            return nil
        }
        
        init(firstName: String, lastName: String, middleName: String, namePrefix: String, nameSuffix: String, nameType: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.middleName = middleName
            self.namePrefix = namePrefix
            self.nameSuffix = nameSuffix
            self.nameType = nameType
        }
    }
    
    func initNames(rawData: AnyObject) -> Bool {
        // Passed in a dictionary
        if let dataDict = rawData as? Dictionary<String, String> {
            if let newName: Name = Name.newName(dataDict) {
                self.names = [newName]
                return true
            }
            return false
        }
        
        // Passed in an array of dictionary
        if let dataArray = rawData as? [Dictionary<String, String>] {
            var tempNames = [Name]()
            for eachDataDict in dataArray {
                if let newName: Name = Name.newName(eachDataDict) {
                    tempNames.append(newName)
                } else {
                    // Some error happens
                    self.names = []
                    return false
                }
            }
            // If goes here, no error happens
            self.names = tempNames
            return true
        }
        // Invalid type
        return false
    }

    class PhoneNumber {
        var type: String
        var country: String
        var ext: String
        var isPreferred: Bool
        var telephone: String
        
        class func kPhoneType() -> String {return "phone_type"}
        class func kCountry() -> String {return "country"}
        class func kExtension() -> String {return "ext"}
        class func kPreferred() -> String {return "preferred"}
        class func kTelephone() -> String {return "telephone"}
        
        class func newPhoneNumber(rawDict: Dictionary<String, String>) -> PhoneNumber? {
            let phoneType: String? = rawDict[PhoneNumber.kPhoneType()]
            let country: String? = rawDict[PhoneNumber.kCountry()]
            let ext: String? = rawDict[PhoneNumber.kExtension()]
            let preferredString: String? = rawDict[PhoneNumber.kPreferred()]
            let preferred: Bool = preferredString == "Y" ? true : false
            let telephone: String? = rawDict[PhoneNumber.kTelephone()]
            
            if (phoneType != nil) && (country != nil) && (ext != nil) && (preferredString != nil) && (telephone != nil) {
                return PhoneNumber(type: phoneType!, country: country!, ext: ext!, isPreferred: preferred, telephone: telephone!)
            }
            return nil
        }
        
        init (type: String, country: String, ext: String, isPreferred: Bool, telephone: String) {
            self.type = type
            self.country = country
            self.ext = ext
            self.isPreferred = isPreferred
            self.telephone = telephone
        }
    }
    
    func initPhoneNumbers(rawData: AnyObject) -> Bool {
        // Passed in a dictionary
        if let dataDict = rawData as? Dictionary<String, String> {
            if let newPhoneNumber: PhoneNumber = PhoneNumber.newPhoneNumber(dataDict) {
                self.phoneNumbers = [newPhoneNumber]
                return true
            }
            return false
        }
        
        // Passed in an array of dictionary
        if let dataArray = rawData as? [Dictionary<String, String>] {
            var tempPhoneNumber = [PhoneNumber]()
            for eachDataDict in dataArray {
                if let newPhoneNumber: PhoneNumber = PhoneNumber.newPhoneNumber(eachDataDict) {
                    tempPhoneNumber.append(newPhoneNumber)
                } else {
                    // Some error happens
                    self.phoneNumbers = []
                    return false
                }
            }
            // If goes here, no error happens
            self.phoneNumbers = tempPhoneNumber
            return true
        }
        // Invalid type
        return false
    }
    
    class EmailAddress {
        // Alternate email address
        class Email {
            var type: String
            var address: String
            class func kType() -> String {return "email_type"}
            class func kAddress() -> String {return "email_address"}
            
            class func newEmail(rawDict: Dictionary<String, String>) -> Email? {
                let type: String? = rawDict[kType()]
                let address: String? = rawDict[kAddress()]
                if (type != nil) && (address != nil) {
                    return Email(type: type!, address: address!)
                }
                return nil
            }
            
            init(type: String, address: String) {
                self.type = type
                self.address = address
            }
        }

        class CampusEmail {
            var campusEmail: String
            var deliveredTo: String
            class func kCampusEmail() -> String {return "campus_email"}
            class func kDeliveredTo() -> String {return "delivered_to"}
            
            class func newCampusEmail(rawDict: Dictionary<String, String>) -> CampusEmail? {
                let campusEmail: String? = rawDict[kCampusEmail()]
                let deliveredTo: String? = rawDict[kDeliveredTo()]
                if (campusEmail != nil) && (deliveredTo != nil) {
                    return CampusEmail(campusEmail: campusEmail!, deliveredTo: deliveredTo!)
                }
                return nil
            }
            
            init(campusEmail: String, deliveredTo: String) {
                self.campusEmail = campusEmail
                self.deliveredTo = deliveredTo
            }
        }
        
        var alternateEmailAddress: [Email]!
        var alternateEmailDescription: String?
        
        var campusEmailAddress: CampusEmail!
        var campusEmailDescription: String?
        
        var description: String?
        
        init(description: String?, alternateEmails: [Email], alternateEmailDescription: String?, campusEmail: CampusEmail, campusEmailDescription: String?) {
            self.description = description
            self.alternateEmailAddress = alternateEmails
            self.alternateEmailDescription = alternateEmailDescription
            self.campusEmailAddress = campusEmail
            self.campusEmailDescription = campusEmailDescription
        }
    }
    
    func initEmailAddresses(rawData: AnyObject) -> Bool {
        if let dataDict = rawData as? Dictionary<String, AnyObject> {
            let description: String? = dataDict["description"] as AnyObject? as? String
            let alternateEmailAddressDict: Dictionary<String, AnyObject>? = dataDict["alternate_email_address"] as AnyObject? as? Dictionary<String, AnyObject>
            let campusEmailAddressDict: Dictionary<String, AnyObject>? = dataDict["campus_email_address"] as AnyObject? as? Dictionary<String, AnyObject>
            
            if (alternateEmailAddressDict != nil) && (campusEmailAddressDict != nil) {
                let alternateEmailDescription: String? = alternateEmailAddressDict!["description"] as AnyObject? as? String
                let alternateEmailData: [Dictionary<String, String>]? = alternateEmailAddressDict!["data"] as AnyObject? as? [Dictionary<String, String>]
                
                let campusEmailDescription: String? = campusEmailAddressDict!["description"] as AnyObject? as? String
                let campusEmailData: [Dictionary<String, String>]? = campusEmailAddressDict!["data"] as AnyObject? as? [Dictionary<String, String>]
                if (alternateEmailData != nil) && (campusEmailData != nil) {
                    var tempAlternateEmails: [EmailAddress.Email] = []
                    for eachAlternateEmail in alternateEmailData! {
                        if let newEmail = EmailAddress.Email.newEmail(eachAlternateEmail) {
                            tempAlternateEmails.append(newEmail)
                        } else {
                            // Some error happens
                            return false
                        }
                    }
                    let campusEmail: EmailAddress.CampusEmail? = EmailAddress.CampusEmail.newCampusEmail(campusEmailData![0])
                    if (campusEmail != nil) {
                        // Successfully
                        self.emailAddresses = EmailAddress(description: description, alternateEmails: tempAlternateEmails, alternateEmailDescription: alternateEmailDescription, campusEmail: campusEmail!, campusEmailDescription: campusEmailDescription)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    class EmergencyContact {
        var contactName: String
        var country: String
        var ext: String
        var phone: String
        var isPrimary: Bool
        var relationship: String
        
        class func kContactName() -> String {return "contact_name"}
        class func kCountry() -> String {return "country"}
        class func kExtension() -> String {return "extension"}
        class func kPhone() -> String {return "phone"}
        class func kPrimary() -> String {return "primary_contact"}
        class func kRelationship() -> String {return "relationship"}
        
        class func newContact(rawDict: Dictionary<String, String>) -> EmergencyContact? {
            let contactName: String? = rawDict[EmergencyContact.kContactName()]
            let country: String? = rawDict[EmergencyContact.kCountry()]
            let ext: String? = rawDict[EmergencyContact.kExtension()]
            let phone: String? = rawDict[EmergencyContact.kPhone()]
            let primaryString: String? = rawDict[EmergencyContact.kPrimary()]
            let isPrimary: Bool = primaryString == "Y" ? true : false
            let relationship: String? = rawDict[EmergencyContact.kRelationship()]
            
            if (contactName != nil) && (country != nil) && (ext != nil) && (phone != nil) && (primaryString != nil) && (relationship != nil) {
                return EmergencyContact(contactName: contactName!, country: country!, ext: ext!, phone: phone!, isPrimary: isPrimary, relationship: relationship!)
            }
            return nil
        }

        
        init (contactName: String, country: String, ext: String, phone: String, isPrimary: Bool, relationship: String) {
            self.contactName = contactName
            self.country = country
            self.ext = ext
            self.phone = phone
            self.isPrimary = isPrimary
            self.relationship = relationship
        }
    }
    
    func initEmergencyContacts(rawData: AnyObject) -> Bool {
        // Passed in a dictionary
        if let dataDict = rawData as? Dictionary<String, String> {
            if let newContact: EmergencyContact = EmergencyContact.newContact(dataDict) {
                self.emergencyContacts = [newContact]
                return true
            }
            return false
        }
        
        // Passed in an array of dictionary
        if let dataArray = rawData as? [Dictionary<String, String>] {
            var tempContancts = [EmergencyContact]()
            for eachDataDict in dataArray {
                if let newContact: EmergencyContact = EmergencyContact.newContact(eachDataDict) {
                    tempContancts.append(newContact)
                } else {
                    // Some error happens
                    self.emergencyContacts = []
                    return false
                }
            }
            // If goes here, no error happens
            self.emergencyContacts = tempContancts
            return true
        }
        // Invalid type
        return false
    }
    
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