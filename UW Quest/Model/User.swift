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
    
    var personalInformation: PersonalInformation = PersonalInformation()
    
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
            success?()
        }) { (errorMessage, error) -> () in
            self.isLoggedIn = false
            ARAnalytics.error(error, withMessage: errorMessage)
            failure?(errorMessage: errorMessage, error: error)
            return
        }
    }
    
    func getPersonalInformation(type: PersonalInformationType, success: (() -> ())?, failure:((errorMessage: String, error: NSError?) -> ())?) {
        if !self.isLoggedIn {
            failure!(errorMessage: "User is not logged in", error: nil)
        }

        Locator.sharedLocator.client.getPersonalInformation(type, success: { (dataResponse) -> () in
            if self.processPersonalInformation(type, data: dataResponse) {
                success?()
            }
        }) { (errorMessage, error) -> () in
            failure?(errorMessage: errorMessage, error: error)
            return
        }
    }
    
    // User dataResponse (either Dict or Array) to init personal information
    func processPersonalInformation(type: PersonalInformationType, data: AnyObject) -> Bool {
        println("Type: \(type.toRaw())")
        println("Data: \(data)")
        switch type {
        case .Addresses:
            return self.personalInformation.initAddresses(data)
        case .Names:
            break
        case .PhoneNumbers:
            break
        case .EmailAddresses:
            break
        case .EmergencyContacts:
            break
        case .DemographicInformation:
            break
        case .CitizenshipImmigrationDocuments:
            break
        default:
            assert(false, "Wrong PersonalInformation Type")
        }
        return false
    }
}