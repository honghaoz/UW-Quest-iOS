//
//  QuestClient.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-16.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

//TODO: Add reachability manager

let kUWQuestAPIKey: String = "77881122"
let kUWQuestAPIBaseURL: String = "http://uw-quest.appspot.com"

let kStatusSuccess: String = "success"
let kErrorCodeInvalidKey: Int = 1
let kErrorCodeInvalidSID: Int = 2
let kErrorCodeInvalidSession: Int = 3
let kErrorCodeInvalidUseridPassword: Int = 4
let kErrorCodeParseContent: Int = 5
let kErrorCodeOther: Int = 6
let kErrorNetwork: Int = 11

private let _sharedClient = QuestClient(baseURL: NSURL(string: kUWQuestAPIBaseURL))

class QuestClient: AFHTTPSessionManager {
    
    var sid: String? = ""
    
    override init(baseURL url: NSURL!) {
        super.init(baseURL: url)
        setupSerializer()
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        setupSerializer()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSerializer()
    }
    
    func setupSerializer() {
        self.responseSerializer = AFJSONResponseSerializer()
        self.requestSerializer = AFHTTPRequestSerializer()
    }
    
    class var sharedClient: QuestClient {
        return _sharedClient
    }
    
    // MARK: Operations
    func login(username: String!, password: String!, success:() -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
        if username.isEmpty || password.isEmpty {
            failure(errorMessage: "Userid or password can not be emptys", error: nil)
            return
        }
        
        let path = "login"
        let parameters: Dictionary = [
            "userid": username,
            "password": password,
            "key": kUWQuestAPIKey
        ]
        
        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
            println(responseObject)
            
            let responseDict = responseObject as Dictionary<String, AnyObject>
            if self.statusIsSuccess(responseDict) {
                self.sid = self.getSid(responseDict)
                if (self.sid != nil) {
                    // Login successfully
                    success()
                    return
                }
            }
            // Login failed
            let errorCode = self.getErrorCode(responseDict)
            failure(errorMessage: self.errorMessageWithErrorCode(errorCode), error: NSError(domain: "Not network error", code: 1, userInfo: nil))
        }) { (task, error) -> Void in
            // Network error
            println(error.localizedDescription)
            failure(errorMessage: self.errorMessageWithErrorCode(kErrorNetwork), error: error)
        }
    }
    
    func getPersonalInformation(type: User.PersonalInformationType, success:(data: AnyObject!) -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
        assert(((self.sid != nil) && (!self.sid!.isEmpty)) as Bool, "SID must be non-empty")
        var path = "personalinformation/"
        switch type {
        case .Addresses:
            path += "addresses"
        case .Names:
            path += "names"
        case .PhoneNumbers:
            path += "phone_numbers"
        case .EmailAddresses:
            path += "email_addresses"
        case .EmergencyContacts:
            path += "emergency_contacts"
        case .DemographicInformation:
            path += "demographic_information"
        case .CitizenshipImmigrationDocuments:
            path += "citizenship_immigration_documents"
        default: assert(false, "Wrong PersonalInformation Type")
        }
        
        let parameters: Dictionary = [
            "sid": self.sid!,
            "key": kUWQuestAPIKey
        ]
        
        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
            let responseDict = responseObject as Dictionary<String, AnyObject>
            if self.statusIsSuccess(responseDict) {
                // Get data successfully
                if let data: AnyObject = responseDict["data"] {
                    success(data: data)
                }
            } else {
                // Get data failed
                // TODO:
                failure(errorMessage: "TODOTODO", error: nil)
            }
            
        }) { (task, error) -> Void in
            println(error.localizedDescription)
            failure(errorMessage: self.errorMessageWithErrorCode(kErrorNetwork), error: error)
        }
    }
    
    //MARK: Helpers
    private func getSid(responseDict: Dictionary<String, AnyObject>) -> String? {
        if let data: AnyObject = responseDict["data"] {
            if let sid = data["sid"] as? String {
                return sid
            }
        }
        return nil
    }
    
    private func getErrorCode(responseDict: Dictionary<String, AnyObject>) -> Int {
        if let meta: AnyObject = responseDict["meta"] {
            if let code = meta["error_code"] as? Int {
                return code
            }
        }
        return 0
    }
    
    private func statusIsSuccess(responseDict: Dictionary<String, AnyObject>) -> Bool {
        if let meta: AnyObject = responseDict["meta"] {
            if let status = meta["status"] as? String {
                return status == kStatusSuccess
            }
        }
        return false
    }
    
    func errorMessageWithErrorCode(code: Int) -> String {
        var message: String = ""
        switch (code) {
        case kErrorCodeInvalidUseridPassword:
            message = "Invalid UserID/Password"
        case kErrorCodeInvalidKey:
            message = "Invalid Key"
        case kErrorCodeInvalidSession:
            message = "Invalid Session"
        case kErrorCodeParseContent:
            message = "Invalid Content"
        case kErrorNetwork:
            message = "Network Error"
        default:
            message = ""
            ARAnalytics.error(NSError(domain: "", code: code, userInfo: nil), withMessage: "")
        }
        return message
    }
}