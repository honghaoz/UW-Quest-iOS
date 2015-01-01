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
    
    var kUsername = "Username"
    var kPassword = "Password"
    var kIsRemembered = "Remembered"
    
    var personalInformation: PersonalInformation = PersonalInformation()
    
    init() {
        logInfo("User inited")
    }
    
    class var sharedUser: User {
        return _sharedUser
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(isRemembered, forKey: kIsRemembered)
        defaults.setObject(username, forKey: kUsername)
        defaults.setObject(password, forKey: kPassword)
        defaults.synchronize()
    }
    
    func load() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.isRemembered = defaults.boolForKey(kIsRemembered)
        if self.isRemembered {
            if let username: AnyObject = defaults.objectForKey(kUsername) {
                self.username = username as String
            }
            if let password: AnyObject = defaults.objectForKey(kPassword) {
                self.password = password as String
            }
            return true
        }
        return false
    }
    
    func login(success:(() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        logInfo("Login: userid: \(username), password: \(password)")
        assert(!username.isEmpty && !password.isEmpty, "userid or password must be non-empty")
        Locator.sharedQuestClient.loginWithUsename(username, password: password, success: { (response, json) -> () in
            self.isLoggedIn = true
            success?()
            ARAnalytics.event("Login successfully")
        }) { (errorMessage, error) -> () in
            self.isLoggedIn = false
            failure?(errorMessage: errorMessage, error: error)
            ARAnalytics.error(error, withMessage: errorMessage)
        }
    }
    
    func getPersonalInformation(type: PersonalInformationType, success: (() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        logVerbose()
        if !self.isLoggedIn {
            failure!(errorMessage: "User is not logged in", error: nil)
        }
        
        Locator.sharedQuestClient.getPersonalInformation(type, success: { (data) -> () in
            if self.processPersonalInformation(type, data: data) {
                success?()
            } else {
                failure?(errorMessage: "Init data failed", error: nil)
            }
        }) { (errorMessage, error) -> () in
            failure?(errorMessage: errorMessage, error: error)
            return
        }
    }
    
    // User dataResponse (either Dict or Array) to init personal information
    func processPersonalInformation(type: PersonalInformationType, data: AnyObject) -> Bool {
        logDebug("Type: \(type.rawValue)")
        logDebug("Data: \(data)")
        switch type {
        case .Addresses:
            return self.personalInformation.initAddresses(data)
        case .Names:
            return self.personalInformation.initNames(data, message: nil)
        case .PhoneNumbers:
            return self.personalInformation.initPhoneNumbers(data, message: nil)
        case .EmailAddresses:
            return self.personalInformation.initEmailAddresses(data, message: nil)
        case .EmergencyContacts:
            return self.personalInformation.initEmergencyContacts(data, message: nil)
        case .DemographicInformation:
            return self.personalInformation.initDemographicInformation(data, message: nil)
        case .CitizenshipImmigrationDocuments:
            return self.personalInformation.initCitizenshipImmigrationDocument(data, message: nil)
        default:
            assert(false, "Wrong PersonalInformation Type")
        }
        return false
    }
}