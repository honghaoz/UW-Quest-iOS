//
//  QuestService.swift
//  UW Quest
//
//  Created by Honghao on 12/30/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

let kQuestLoginURL = "https://quest.pecs.uwaterloo.ca/psp/SS/?cmd=login&languageCd=ENG"
let kQuestLogoutURL = "https://quest.pecs.uwaterloo.ca/psp/SS/ACADEMIC/SA/?cmd=logout"
let kStudentCenterURL_SA = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/SA/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL"
let kStudentCenterURL_HRMS = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL"

private let _sharedService = QuestService(baseURL: NSURL(string: ""))

class QuestService: AFHTTPSessionManager {
    
    var icsid: String = ""
    var currentStateNum: Int = 0
    var currentURLString: String!
    
    var isUndergraduate: Bool = true
    var isLogin: Bool = false
    
    var basicPostData: Dictionary<String, String> {
        return [
        "ICAJAX": "1",
        "ICNAVTYPEDROPDOWN":"0",
        "ICType":"Panel",
        "ICElementNum":"0",
        "ICStateNum": String(currentStateNum),
        "ICAction":"", // Need to change
        "ICXPos":"0",
        "ICYPos":"0",
        "ResponsetoDiffFrame":"-1",
        "TargetFrameName":"None",
        "FacetPath":"None",
        "ICFocus":"",
        "ICSaveWarningFilter":"0",
        "ICChanged":"-1",
        "ICResubmit":"0",
        "ICSID": icsid, // Need to change
        "ICActionPrompt":"false",
        "ICFind":"",
        "ICAddCount":"",
        "ICAPPCLSDATA":"",
        ]
    }
    
    override init(baseURL url: NSURL!) {
        super.init(baseURL: url)
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        logInfo("Service inited")
        self.responseSerializer = AFHTTPResponseSerializer() as AFHTTPResponseSerializer
        self.requestSerializer = AFHTTPRequestSerializer()
        self.reachabilityManager.setReachabilityStatusChangeBlock { (status) -> Void in
            switch status {
            case AFNetworkReachabilityStatus.ReachableViaWWAN, AFNetworkReachabilityStatus.ReachableViaWiFi:
                logInfo(".Reachable")
                self.operationQueue.suspended = false
                break
            case AFNetworkReachabilityStatus.NotReachable:
                logInfo(".NotReachable")
                self.operationQueue.suspended = true
                break
            case AFNetworkReachabilityStatus.Unknown:
                logInfo(".Unknown")
                break
            default:
                break
            }
        }
        self.reachabilityManager.startMonitoring()
    }
    
    class var sharedService: QuestService {
        return _sharedService
    }
}

// MARK: Helper methods
extension QuestService {
    func getHtmlContentFromResponse(response: AnyObject) -> String? {
        let html: String = NSString(data: response as NSData, encoding: NSUTF8StringEncoding)!
        return html
    }
    
    func getICSID(response: AnyObject) -> String? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        let element = html!.peekAtSearchWithXPathQuery("//*[@id=\"ICSID\"]")
        if element != nil {
            return element!.objectForKey("value")
        }
        return nil
    }
    
    func pageIsValid(response: AnyObject) -> Bool {
        let icsid = getICSID(response)
        if icsid == nil {
            return false
        } else {
            return true
        }
    }
    
    func getStateNum(response: AnyObject) -> Int? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        let element = html!.peekAtSearchWithXPathQuery("//*[@id=\"ICStateNum\"]")
        if element != nil {
            return element!.objectForKey("value").toInt()
        }
        return nil
    }
    
    func isCookieExpired() -> Bool {
        let cookie = NSHTTPCookieStorage.cookieForKey("PS_TOKENEXPIRE", urlString: currentURLString)
        let lastUpdateDateString: String = cookie!.value!
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd_MMM_y_HH:mm:ss_z"
        let lastUpdateDate = formatter.dateFromString(lastUpdateDateString)!
        let currentDate = NSDate()
        let interval = currentDate.timeIntervalSinceDate(lastUpdateDate)
        
        if interval >= 20 * 60 {
            logInfo("Cookies is expired")
            return true
        } else {
            logInfo("Cookies is not expired")
            return false
        }
    }
    
    func isOnLoginPage(response: AnyObject) -> Bool {
        let html = getHtmlContentFromResponse(response)
        if html != nil {
            let element = html!.peekAtSearchWithXPathQuery("//*[@id='login']//*[@type='submit']")
            if element != nil {
                if element!.objectForKey("value") == "Sign in" {
                    return true
                }
            }
        }
        return false
    }
    
    func usernamePasswordInvalid(response: AnyObject) -> Bool {
        let html = getHtmlContentFromResponse(response)
        if html != nil {
            let element = html!.peekAtSearchWithXPathQuery("//*[@id='login']//*[@class='PSERRORTEXT']")
            if element != nil {
                if element!.text() == "Your User ID and/or Password are invalid." {
                    return true
                }
            }
        }
        return false
    }
    
    func isUndergraduate(response: AnyObject) -> Bool? {
        //*/table[@id="ACE_DERIVED_SSS_SCL_SS_ACAD_INFO_LINK"]//*/table[@id="ACE_$ICField280"]//tr//a
        let html = getHtmlContentFromResponse(response)
        if html != nil {
            var elements = html!.searchWithXPathQuery("//*/table[@id='ACE_DERIVED_SSS_SCL_SS_ACAD_INFO_LINK']//*/table[@id='ACE_$ICField280']//tr//a")
            var containUndergrad = elements.filter({
                $0.text().containsSubString("Undergrad")
            })
            if containUndergrad.count > 0 {
                return true
            } else {
                return false
            }
        }
        return nil
    }
}

// MARK: Basic operations
extension QuestService {
    func loginWithUsename(username: String, password: String) {
        logVerbose("username: \(username), password: \(password)")
        let parameters: Dictionary = [
            "userid": username,
            "pwd": password,
            "timezoneOffset": "0",
            "httpPort": ""
        ]
        currentURLString = kQuestLogoutURL
        self.POST(kQuestLoginURL, parameters: parameters, success: { (task, response) -> Void in
            logVerbose("success")
            self.gotoStudentCenter()
            }) { (task, error) -> Void in
                logVerbose("failed: \(error.localizedDescription)")
        }
    }
    
    func logout() {
        currentURLString = kQuestLogoutURL
        self.GET(kQuestLogoutURL, parameters: nil, success: { (task, response) -> Void in
            logInfo("Success")
            self.isLogin = false
        }) { (task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
        }
    }
    
    func gotoStudentCenter() {
        logVerbose()
        // https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/SA/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL?PORTALPARAM_PTCNAV=HC_SSS_STUDENT_CENTER&EOPP.SCNode=SA&EOPP.SCPortal=ACADEMIC&EOPP.SCName=CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Self%20Service&EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HC_SSS_STUDENT_CENTER&IsFolder=false&PortalActualURL=https%3a%2f%2fquest.pecs.uwaterloo.ca%2fpsc%2fSS%2fACADEMIC%2fSA%2fc%2fSA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL&PortalRegistryName=ACADEMIC&PortalServletURI=https%3a%2f%2fquest.pecs.uwaterloo.ca%2fpsp%2fSS%2f&PortalURI=https%3a%2f%2fquest.pecs.uwaterloo.ca%2fpsc%2fSS%2f&PortalHostNode=SA&NoCrumbs=yes&PortalKeyStruct=yes
        
        let parameters: Dictionary = [
            "PORTALPARAM_PTCNAV": "HC_SSS_STUDENT_CENTER",
            "EOPP.SCNode": "SA",
            "EOPP.SCPortal": "ACADEMIC",
            "EOPP.SCName": "CO_EMPLOYEE_SELF_SERVICE",
            "EOPP.SCLabel": "Self Service",
            "EOPP.SCPTfname": "CO_EMPLOYEE_SELF_SERVICE",
            "FolderPath": "PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HC_SSS_STUDENT_CENTER",
            "IsFolder": "false",
            "PortalActualURL": "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/SA/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL",
            "PortalRegistryName": "ACADEMIC",
            "PortalServletURI": "https://quest.pecs.uwaterloo.ca/psp/SS/",
            "PortalURI": "https://quest.pecs.uwaterloo.ca/psc/SS/",
            "PortalHostNode": "SA",
            "NoCrumbs": "yes",
            "PortalKeyStruct": "yes"
        ]
        
        currentURLString = kStudentCenterURL_SA
        self.GET(kStudentCenterURL_SA, parameters: parameters, success: { (task, response) -> Void in
            logVerbose("Success")
            logDebug("isUndergrad: \(self.isUndergraduate(response))")
            logDebug("ICSID: \(self.getICSID(response)?)")
            logDebug("StateNum: \(self.getStateNum(response)?)")
            self.isCookieExpired()
            }) { (task, error) -> Void in
                logVerbose("Failed: \(error.localizedDescription)")
        }
    }
}