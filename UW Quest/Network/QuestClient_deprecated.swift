////
////  QuestClient1.swift
////  UW Quest
////
////  Created by Honghao Zhang on 2014-09-16.
////  Copyright (c) 2014 Honghao. All rights reserved.
////
//
//import Foundation
//
//let kUWQuestAPIKey: String = "77881122"
//let kUWQuestAPIBaseURL: String = "http://uw-quest.appspot.com"
//
//let kStatusSuccess: String = "success"
//let kErrorCodeInvalidKey: Int = 1
//let kErrorCodeInvalidSID: Int = 2
//let kErrorCodeInvalidSession: Int = 3
//let kErrorCodeInvalidUseridPassword: Int = 4
//let kErrorCodeParseContent: Int = 5
//let kErrorCodeOther: Int = 6
//let kErrorNetwork: Int = 11
//
//private let _sharedClient1 = QuestClient1(baseURL: NSURL(string: kUWQuestAPIBaseURL))
//
//var onceToken: dispatch_once_t = 0
//
//class QuestClient1: AFHTTPSessionManager {
//    
//    var sid: String? = ""
//    
//    override init(baseURL url: NSURL!) {
//        super.init(baseURL: url)
//        setup()
//    }
//    
//    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
//        super.init(baseURL: url, sessionConfiguration: configuration)
//        setup()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
//    }
//    
//    func setup() {
//        println("Client inited")
//        self.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
//        self.requestSerializer = AFHTTPRequestSerializer()
//        self.reachabilityManager.setReachabilityStatusChangeBlock { (status) -> Void in
//            switch status {
//            case AFNetworkReachabilityStatus.ReachableViaWWAN, AFNetworkReachabilityStatus.ReachableViaWiFi:
//                println("AFNetworkReachabilityStatus.Reachable")
//                self.operationQueue.suspended = false
//            case AFNetworkReachabilityStatus.NotReachable:
//                println("AFNetworkReachabilityStatus.NotReachable")
//                self.operationQueue.suspended = true
//            case AFNetworkReachabilityStatus.Unknown:
//                println("AFNetworkReachabilityStatus.Unknown")
//            default:
//                break
//            }
//        }
//        self.reachabilityManager.startMonitoring()
//        self.activate()
//    }
//    
//    class var sharedClient: QuestClient1 {
//        return _sharedClient1
//    }
//    
//    func activate() {
//        dispatch_once(&onceToken, { () -> Void in
//            println("API start to activate...")
//            let parameters: Dictionary = [
//                "key": kUWQuestAPIKey
//            ]
//            self.GET("activate", parameters: parameters, success: { (task, responseObject) -> Void in
//                // TODO: change API to response json
//                println("API activated successfully")
//                let response: NSHTTPURLResponse? = task.response as? NSHTTPURLResponse
//                println("status code: \(response?.statusCode)")
//                
//                }, failure: { (task, error) -> Void in
//                    println("API activated failed")
//                    let response: NSHTTPURLResponse? = task.response as? NSHTTPURLResponse
//                    println("status code: \(response?.statusCode)")
//                    // Status code is 503/500 for server down
//            })
//        })
//    }
//    
//    // MARK: Operations
//    func login(username: String!, password: String!, success:() -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
//        if username.isEmpty || password.isEmpty {
//            failure(errorMessage: "Userid or password can not be emptys", error: nil)
//            return
//        }
//        
//        let path = "login"
//        let parameters: Dictionary = [
//            "userid": username,
//            "password": password,
//            "key": kUWQuestAPIKey
//        ]
//        
//        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
//            println(responseObject)
//            
//            let responseDict = responseObject as Dictionary<String, AnyObject>
//            if self.statusIsSuccess(responseDict) {
//                self.sid = self.getSid(responseDict)
//                if (self.sid != nil) {
//                    // Login successfully
//                    success()
//                    return
//                }
//            }
//            // Login failed
//            let errorCode = self.getErrorCode(responseDict)
//            failure(errorMessage: self.errorMessageWithErrorCode(errorCode), error: NSError(domain: "Not network error", code: 1, userInfo: nil))
//        }) { (task, error) -> Void in
//            // Network error
//            println(error.localizedDescription)
//            failure(errorMessage: self.errorMessageWithErrorCode(kErrorNetwork), error: error)
//        }
//    }
//    
//    func getPersonalInformation(type: PersonalInformationType, success:(data: AnyObject!, message: String?) -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
//        assert(((self.sid != nil) && (!self.sid!.isEmpty)) as Bool, "SID must be non-empty")
//        var path = "personalinformation/"
//        switch type {
//        case .Addresses:
//            path += "addresses"
//        case .Names:
//            path += "names"
//        case .PhoneNumbers:
//            path += "phone_numbers"
//        case .EmailAddresses:
//            path += "email_addresses"
//        case .EmergencyContacts:
//            path += "emergency_contacts"
//        case .DemographicInformation:
//            path += "demographic_information"
//        case .CitizenshipImmigrationDocuments:
//            path += "citizenship_immigration_documents"
//        default: assert(false, "Wrong PersonalInformation Type")
//        }
//        
//        let parameters: Dictionary = [
//            "sid": self.sid!,
//            "key": kUWQuestAPIKey
//        ]
//        
//        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
//            let responseDict = responseObject as Dictionary<String, AnyObject>
//            if self.statusIsSuccess(responseDict) {
//                // Get data successfully
//                if let data: AnyObject = responseDict["data"] {
//                    success(data: data, message: self.getMessage(responseDict))
//                }
//            } else {
//                // Get data failed
//                // TODO:
//                let errorCode = self.getErrorCode(responseDict)
//                failure(errorMessage: self.errorMessageWithErrorCode(errorCode), error: NSError(domain: "Not network error", code: 1, userInfo: nil))
//            }
//            
//        }) { (task, error) -> Void in
//            println(error.localizedDescription)
//            failure(errorMessage: self.errorMessageWithErrorCode(kErrorNetwork), error: error)
//        }
//    }
//    
//    //MARK: Helpers
//    private func getSid(responseDict: Dictionary<String, AnyObject>) -> String? {
//        if let data: AnyObject = responseDict["data"] {
//            if let sid = data["sid"] as? String {
//                return sid
//            }
//        }
//        return nil
//    }
//    
//    private func getErrorCode(responseDict: Dictionary<String, AnyObject>) -> Int {
//        if let meta: AnyObject = responseDict["meta"] {
//            if let code = meta["error_code"] as? Int {
//                return code
//            }
//        }
//        return 0
//    }
//    
//    private func statusIsSuccess(responseDict: Dictionary<String, AnyObject>) -> Bool {
//        if let meta: AnyObject = responseDict["meta"] {
//            if let status = meta["status"] as? String {
//                return status == kStatusSuccess
//            }
//        }
//        return false
//    }
//    
//    private func getMessage(responseDict: Dictionary<String, AnyObject>) -> String? {
//        if let meta: AnyObject = responseDict["meta"] {
//            if let message = meta["message"] as? String {
//                if !(message.isEmpty) {
//                    return message
//                }
//            }
//        }
//        return nil
//    }
//    
//    func errorMessageWithErrorCode(code: Int) -> String {
//        var message: String = ""
//        switch (code) {
//        case kErrorCodeInvalidUseridPassword:
//            message = "Invalid UserID/Password"
//        case kErrorCodeInvalidKey:
//            message = "Invalid Key"
//        case kErrorCodeInvalidSession:
//            message = "Invalid Session"
//        case kErrorCodeParseContent:
//            message = "Invalid Content"
//        case kErrorNetwork:
//            message = "Network Error"
//        default:
//            message = ""
//            ARAnalytics.error(NSError(domain: "", code: code, userInfo: nil), withMessage: "")
//        }
//        return message
//    }
//}