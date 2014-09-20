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
    
    func login(username: String!, password: String!) {
        if username.isEmpty || password.isEmpty {
            JGProgressHUD.showFailure("Failed!")
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
                    Locator.sharedLocator.user.isLoggedIn = true
                    JGProgressHUD.showSuccess("Success!")
                    return
                }
            }
            // Login failed
            Locator.sharedLocator.user.isLoggedIn = false
            self.showErrorWithCode(self.getErrorCode(responseDict))
        }) { (task, error) -> Void in
            println(error.localizedDescription)
            JGProgressHUD.showFailure("Network Error!")
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
    
    private func showErrorWithCode(code: Int) {
        switch (code) {
        case kErrorCodeInvalidUseridPassword:
            JGProgressHUD.showFailure("Invalid UserID/Password")
        case kErrorCodeInvalidKey:
            JGProgressHUD.showFailure("Invalid Key")
        case kErrorCodeInvalidSession:
            JGProgressHUD.showFailure("Invalid Session")
        case kErrorCodeParseContent:
            JGProgressHUD.showFailure("Invalid Content")
        default:
            ARAnalytics.error(NSError(domain: "", code: code, userInfo: nil), withMessage: "")
        }
        
    }
}