//
//  User.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-15.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

private let _sharedUser = User()

class User {
    var username: String = ""
    var password: String = ""
    var isRemembered: Bool = true
    var isLoggedIn: Bool = false
    
    enum PersonalInfomation: String {
        case Addresses = "Addresses"
        case Names = "Names"
        case PhoneNumbers = "Phone Numbers"
        case EmailAddresses = "Email Addresses"
        case EmergencyContacts = "Emergency Contacts"
        case DemographicInformation = "Demographic Information"
        case CitizenshipImmigrationDocuments = "Citizenship/Immigration Documents"
    }
    
    
    init() {
        println("User inited")
    }
    
    class var sharedUser: User {
        return _sharedUser
    }
    
    func login(success:(() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        println("Login: userid: \(username), password: \(password)")
        assert(!username.isEmpty && !password.isEmpty, "userid or password must be non-empty")
        Locator.sharedLocator.client.login(username, password: password, success: { () -> () in
            self.isLoggedIn = true
            ARAnalytics.event("Login successfully")
            success!()
        }) { (errorMessage, error) -> () in
            self.isLoggedIn = false
            ARAnalytics.error(error, withMessage: errorMessage)
            failure!(errorMessage: errorMessage, error: error)
        }
    }
    
    func getPersonalInformation(type: PersonalInfomation, success: (() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        if !self.isLoggedIn {
            failure!(errorMessage: "User is not logged in", error: nil)
        }
        
        Locator.sharedLocator.client.getPersonalInformation(type, success: { (dataDict) -> () in
            println("\(dataDict)")
            // User dataDict to init personal information
            success!()
        }) { (errorMessage, error) -> () in
            failure!(errorMessage: errorMessage, error: error)
        }
    }
    
    func processPersonalInformation(data: Dictionary<String, AnyObject>) {
        
    }
}