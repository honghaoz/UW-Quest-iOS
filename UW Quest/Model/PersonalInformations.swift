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
    
    static let allValues = [Addresses.rawValue, Names.rawValue, PhoneNumbers.rawValue, EmailAddresses.rawValue, EmergencyContacts.rawValue, DemographicInformation.rawValue, CitizenshipImmigrationDocuments.rawValue]
}

class PersonalInformation {
    
    let categories: [String]!
    
    var addresses: [Address]!
    var names: [Name]!
    var namesMessage: String?
    var phoneNumbers: [PhoneNumber]!
    var phoneNumbersMessage: String?
    var emailAddresses: EmailAddress?
    var emailAddressesMessage: String?
    var emergencyContacts: [EmergencyContact]!
    var emergencyContactsMessage: String?
    var demograhicInformation: DemographicInformation?
    var demograhicInformationMessage: String?
    var citizenshipImmigrationDocument: CitizenshipImmigrationDocument?
    var citizenshipImmigrationDocumentMessage: String?
    
    init() {
        logInfo("PersonalInformation inited")
        categories = PersonalInformationType.allValues
        addresses = []
        names = []
        phoneNumbers = []
        emergencyContacts = []
    }
    
    class Address {
        // Keys
        class var kAddress: String {return "Address"}
        class var kAddressType: String {return "Address Type"}
        class func newAddress(rawDict: Dictionary<String, String>) -> Address? {
            if let address: String = rawDict[Address.kAddress] {
                if let addressType: String = rawDict[Address.kAddressType] {
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
        var name: String
        var nameType: String
        
        class var kName: String {return "Name"}
        class var kNameType: String {return "Name Type"}
        
        class func newName(rawDict: Dictionary<String, String>) -> Name? {
            let name: String? = rawDict[Name.kName]
            let nameType: String? = rawDict[Name.kNameType]
            
            if (name != nil) && (nameType != nil) {
                return Name(name: name!, nameType: nameType!)
            }
            return nil
        }
        
        init(name: String, nameType: String) {
            self.name = name
            self.nameType = nameType
        }
    }
    
    func initNames(rawData: AnyObject, message: String? = nil) -> Bool {
        self.namesMessage = message
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
        
        class var kPhoneType: String {return "*Phone Type"}
        class var kCountry: String {return "Country"}
        class var kExtension: String {return "Ext"}
        class var kPreferred: String {return "Preferred"}
        class var kTelephone: String {return "*Telephone"}
        
        class func newPhoneNumber(rawDict: Dictionary<String, String>) -> PhoneNumber? {
            let phoneType: String? = rawDict[PhoneNumber.kPhoneType]
            let country: String? = rawDict[PhoneNumber.kCountry]
            let ext: String? = rawDict[PhoneNumber.kExtension]
            let preferredString: String? = rawDict[PhoneNumber.kPreferred]
            let preferred: Bool = preferredString == "Y" ? true : false
            let telephone: String? = rawDict[PhoneNumber.kTelephone]
            
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
    
    func initPhoneNumbers(rawData: AnyObject, message: String? = nil) -> Bool {
        self.phoneNumbersMessage = message
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
            class var kType: String {return "email_type"}
            class var kAddress: String {return "email_address"}
            
            class func newEmail(rawDict: Dictionary<String, String>) -> Email? {
                let type: String? = rawDict[kType]
                let address: String? = rawDict[kAddress]
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
            class var kCampusEmail: String {return "campus_email"}
            class var kDeliveredTo: String {return "delivered_to"}
            
            class func newCampusEmail(rawDict: Dictionary<String, String>) -> CampusEmail? {
                let campusEmail: String? = rawDict[kCampusEmail]
                let deliveredTo: String? = rawDict[kDeliveredTo]
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
    
    func initEmailAddresses(rawData: AnyObject, message: String? = nil) -> Bool {
        self.emailAddressesMessage = message
        if let dataDict = rawData as? Dictionary<String, AnyObject> {
            let description: String? = dataDict["description"] as AnyObject? as? String
            let alternateEmailAddressDict: Dictionary<String, AnyObject>? = dataDict["alternate_email_address"] as AnyObject? as? Dictionary<String, AnyObject>
            let campusEmailAddressDict: Dictionary<String, AnyObject>? = dataDict["campus_email_address"] as AnyObject? as? Dictionary<String, AnyObject>
            
            if (campusEmailAddressDict != nil) {
                let alternateEmailDescription: String? = alternateEmailAddressDict?["description"] as AnyObject? as? String
                let alternateEmailData: [Dictionary<String, String>]? = alternateEmailAddressDict?["data"] as AnyObject? as? [Dictionary<String, String>]
                
                let campusEmailDescription: String? = campusEmailAddressDict!["description"] as AnyObject? as? String
                let campusEmailData: [Dictionary<String, String>]? = campusEmailAddressDict!["data"] as AnyObject? as? [Dictionary<String, String>]
                if (campusEmailData != nil) {
                    var tempAlternateEmails: [EmailAddress.Email] = []
                    if (alternateEmailData != nil) {
                        for eachAlternateEmail in alternateEmailData! {
                            if let newEmail = EmailAddress.Email.newEmail(eachAlternateEmail) {
                                tempAlternateEmails.append(newEmail)
                            } else {
                                // Some error happens
                                return false
                            }
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
        
        class var kContactName: String {return "contact_name"}
        class var kCountry: String {return "country"}
        class var kExtension: String {return "extension"}
        class var kPhone: String {return "phone"}
        class var kPrimary: String {return "primary_contact"}
        class var kRelationship: String {return "relationship"}
        
        class func newContact(rawDict: Dictionary<String, String>) -> EmergencyContact? {
            let contactName: String? = rawDict[EmergencyContact.kContactName]
            let country: String? = rawDict[EmergencyContact.kCountry]
            let ext: String? = rawDict[EmergencyContact.kExtension]
            let phone: String? = rawDict[EmergencyContact.kPhone]
            let primaryString: String? = rawDict[EmergencyContact.kPrimary]
            let isPrimary: Bool = primaryString == "Y" ? true : false
            let relationship: String? = rawDict[EmergencyContact.kRelationship]
            
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
    
    func initEmergencyContacts(rawData: AnyObject, message: String? = nil) -> Bool {
        self.emergencyContactsMessage = message
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
    
    
    class DemographicInformation {
        
        class CitizenshipInformation {
            var country: String
            var description: String
            
            class var kCountry: String {return "country"}
            class var kDescription: String {return "description"}
            
            class func newCitizenshipInformations(rawData: [Dictionary<String, String>]) -> [CitizenshipInformation]? {
                var tempList: [CitizenshipInformation] = []
                for eachDict in rawData {
                    let country: String? = eachDict[CitizenshipInformation.kCountry]
                    let description: String? = eachDict[CitizenshipInformation.kDescription]
                    if (country != nil) && (description != nil) {
                        tempList.append(CitizenshipInformation(country: country!, description: description!))
                    } else {
                        return nil
                    }
                }
                return tempList
            }
            
            init(country: String, description: String) {
                self.country = country
                self.description = description
            }
        }
        var citizenshipInformations: [CitizenshipInformation]?
        
        class Demographic {
            var dateOfBirth: String
            var gender: String
            var id: String
            var maritalStatus: String
            
            class var kDateOfBirth: String {return "date_of_birth"}
            class var kGender: String {return "gender"}
            class var kId: String {return "id"}
            class var kMaritalStatus: String {return "marital_status"}
            
            class func newDemographic(rawDict: Dictionary<String, String>) -> Demographic? {
                let dateOfBirth: String? = rawDict[Demographic.kDateOfBirth]
                let gender: String? = rawDict[Demographic.kGender]
                let id: String? = rawDict[Demographic.kId]
                let maritalStatus: String? = rawDict[Demographic.kMaritalStatus]
                
                if (dateOfBirth != nil) && (gender != nil) && (id != nil) && (maritalStatus != nil) {
                    return Demographic(dateOfBirth: dateOfBirth!, gender: gender!, id: id!, maritalStatus: maritalStatus!)
                } else {
                    return nil
                }
            }
            
            init(dateOfBirth: String, gender: String, id: String, maritalStatus: String) {
                self.dateOfBirth = dateOfBirth
                self.gender = gender
                self.id = id
                self.maritalStatus = maritalStatus
            }
        }
        
        var demographicInfo: Demographic?
        
        class NationalIdentificationNumber {
            var country: String
            var nationalId: String
            var nationalIdType: String
            
            class var kCountry: String {return "country"}
            class var kNationalId: String {return "national_id"}
            class var kNationalIdType: String {return "national_id_type"}
            
            class func newNationalIds(rawData: [Dictionary<String, String>]) -> [NationalIdentificationNumber]? {
                var tempList: [NationalIdentificationNumber] = []
                for eachDict in rawData {
                    let country: String? = eachDict[NationalIdentificationNumber.kCountry]
                    let nationalId: String? = eachDict[NationalIdentificationNumber.kNationalId]
                    let nationalIdType: String? = eachDict[NationalIdentificationNumber.kNationalIdType]
                    if (country != nil) && (nationalId != nil) && (nationalIdType != nil) {
                        tempList.append(NationalIdentificationNumber(country: country!, nationalId: nationalId!, nationalIdType: nationalIdType!))
                    } else {
                        return nil
                    }
                }
                return tempList
            }
            
            init(country: String, nationalId: String, nationalIdType: String) {
                self.country = country
                self.nationalId = nationalId
                self.nationalIdType = nationalIdType
            }
        }
        
        var nationalIdNumbers: [NationalIdentificationNumber]?
        var note: String?
        
        class VisaOrPermitData {
            var country: String
            var type: String
            
            class var kCountry: String {return "country"}
            class var kType: String {return "type"}
            
            class func newVisa(rawDict: Dictionary<String, String>) -> VisaOrPermitData? {
                let country: String? = rawDict[VisaOrPermitData.kCountry]
                let type: String? = rawDict[VisaOrPermitData.kType]
                if (country != nil) && (type != nil) {
                    return VisaOrPermitData(country: country!, type: type!)
                } else {
                    return nil
                }
            }
            
            init(country: String, type: String) {
                self.country = country
                self.type = type
            }
        }
        var visaOrPermitData: VisaOrPermitData?
    }
    
    func initDemographicInformation(rawData: AnyObject, message: String? = nil) -> Bool {
        self.demograhicInformationMessage = message
        let citizenshipsData: [Dictionary<String, String>]? = rawData["citizenship_information"] as AnyObject? as? [Dictionary<String, String>]
        let demographicData: Dictionary<String, String>? = rawData["demographic_information"] as AnyObject? as? Dictionary<String, String>
        let nationalIdsData: [Dictionary<String, String>]? = rawData["national_identification_number"] as AnyObject? as? [Dictionary<String, String>]
        let note: String? = rawData["note"] as AnyObject? as? String
        let visaData: Dictionary<String, String>? = rawData["visa_or_permit_data"] as AnyObject? as? Dictionary<String, String>
        if (citizenshipsData != nil) && (demographicData != nil) && (nationalIdsData != nil) && (visaData != nil) {
            self.demograhicInformation = DemographicInformation()
            
            if let citizenshipInfos: [DemographicInformation.CitizenshipInformation] = DemographicInformation.CitizenshipInformation.newCitizenshipInformations(citizenshipsData!) {
                self.demograhicInformation!.citizenshipInformations = citizenshipInfos
            } else {
                return false
            }
            
            if let demographicInfo: DemographicInformation.Demographic = DemographicInformation.Demographic.newDemographic(demographicData!) {
                self.demograhicInformation!.demographicInfo = demographicInfo
            } else {
                return false
            }
            
            if let nationalIdNumbers: [DemographicInformation.NationalIdentificationNumber] = DemographicInformation.NationalIdentificationNumber.newNationalIds(nationalIdsData!) {
                self.demograhicInformation!.nationalIdNumbers = nationalIdNumbers
            } else {
                return false
            }
            
            self.demograhicInformation!.note = note
            
            if let visaOrPermitData: DemographicInformation.VisaOrPermitData = DemographicInformation.VisaOrPermitData.newVisa(visaData!) {
                self.demograhicInformation!.visaOrPermitData = visaOrPermitData
            } else {
//                return false
            }
            return true
        }
        return false
    }

    class CitizenshipImmigrationDocument {
        class visaDocument {
            var country: String
            var dateReceived: String?
            var expirationDate: String?
            var visaType: String
            
            class var kCountry: String {return "country"}
            class var kDateReceived: String {return "date_received"}
            class var kExpirationDate: String {return "expiration_date"}
            class var kVisaType: String {return "visa_type"}
            
            class func newDocument(rawDict: Dictionary<String, String>) -> visaDocument? {
                let country: String? = rawDict[visaDocument.kCountry]
                let dateReceived: String? = rawDict[visaDocument.kDateReceived]
                let expirationDate: String? = rawDict[visaDocument.kExpirationDate]
                let visaType: String? = rawDict[visaDocument.kVisaType]
                if (country != nil) && (visaType != nil) {
                    return visaDocument(country: country!, dateReceived: dateReceived, expirationDate: expirationDate, visaType: visaType!)
                } else {
                    return nil
                }
            }
            
            init (country: String, dateReceived: String?, expirationDate: String?, visaType: String) {
                self.country = country
                self.dateReceived = dateReceived
                self.expirationDate = expirationDate
                self.visaType = visaType
            }
        }
        var requiredDocumentation: [visaDocument]!
        var pastDocumentation: [visaDocument]!
        init() {
            self.requiredDocumentation = []
            self.pastDocumentation = []
        }
    }
    
    func initCitizenshipImmigrationDocument(rawData: AnyObject, message: String? = nil) -> Bool {
        self.citizenshipImmigrationDocumentMessage = message
        println(self.citizenshipImmigrationDocumentMessage)
        let pastDocList: [Dictionary<String, String>]? = rawData["past_documentation"] as AnyObject? as? [Dictionary<String, String>]
        println(pastDocList)
        let requiredDocList: [Dictionary<String, String>]? = rawData["required_documentation"] as AnyObject? as? [Dictionary<String, String>]
        println(requiredDocList)
        if (requiredDocList == nil) && (pastDocList == nil) && (self.citizenshipImmigrationDocumentMessage != nil) {
            println("should here")
            return true
        }
        self.citizenshipImmigrationDocument = CitizenshipImmigrationDocument()
        if requiredDocList != nil {
            var tempDocList: [CitizenshipImmigrationDocument.visaDocument] = []
            for eachDoc in requiredDocList! {
                var newDoc: CitizenshipImmigrationDocument.visaDocument? = CitizenshipImmigrationDocument.visaDocument.newDocument(eachDoc)
                if newDoc != nil {
                    tempDocList.append(newDoc!)
                } else {
                    return false
                }
            }
            self.citizenshipImmigrationDocument!.requiredDocumentation = tempDocList
        } else {
            return false
        }
        
        if pastDocList != nil {
            var tempDocList: [CitizenshipImmigrationDocument.visaDocument] = []
            for eachDoc in pastDocList! {
                var newDoc: CitizenshipImmigrationDocument.visaDocument? = CitizenshipImmigrationDocument.visaDocument.newDocument(eachDoc)
                if newDoc != nil {
                    tempDocList.append(newDoc!)
                } else {
                    return false
                }
            }
            self.citizenshipImmigrationDocument!.pastDocumentation = tempDocList
        }
        return true
    }
}