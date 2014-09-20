//
//  QuestClient.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-16.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

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

@objc protocol QuestClientDelegate {
    optional func didFinishLogin(loginResult: Bool, errorCode: Int, errorMessage: String)
}

private let _sharedClient = QuestClient(baseURL: NSURL(string: kUWQuestAPIBaseURL))

class QuestClient: AFHTTPSessionManager {
    
    var delegate: QuestClientDelegate?
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
    
    func login(username: String!, password: String!) {
        if username.isEmpty || password.isEmpty {
            JGProgressHUD.showFailure("Failed!", duration: 1.5)
            return
        }
        
        // Set User
        Locator.sharedLocator.user.username = username
        Locator.sharedLocator.user.password = password
        
        let path = "login"
        let parameters: Dictionary = [
            "userid": username,
            "password": password,
            "key": kUWQuestAPIKey
        ]
        println("Login: userid: \(username), password: \(password)")
        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
            println(responseObject)
            
            let responseDict = responseObject as Dictionary<String, AnyObject>
            if self.statusIsSuccess(responseDict) {
                self.sid = self.getSid(responseDict)
                if (self.sid != nil) {
                    // Login successfully
                    self.delegate?.didFinishLogin!(true, errorCode: 0, errorMessage: "")
                    return
                }
            }
            // Login failed
            let errorCode = self.getErrorCode(responseDict)
            self.delegate?.didFinishLogin!(false, errorCode: errorCode, errorMessage: self.errorMessageWithErrorCode(errorCode))
        }) { (task, error) -> Void in
            // Network error
            println(error.localizedDescription)
            self.delegate?.didFinishLogin!(false, errorCode: kErrorNetwork, errorMessage: self.errorMessageWithErrorCode(kErrorNetwork))
            ARAnalytics.error(error, withMessage: "Login Error")
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