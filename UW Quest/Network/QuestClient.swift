//
//  QuestClient.swift
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

// Personal Information
let kPersonalInfoAddressURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_ADDRESSES.GBL"
let kPersonalInfoNameURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_NAMES.GBL"
let kPersonalInfoPhoneNumbersURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_PERS_PHONE.GBL"
let kPersonalInfoEmailsURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_EMAIL_ADDR.GBL"
let kPersonalInfoEnergencyURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_EMERG_CNTCT.GBL"
let kPersonalInfoDemographicInfoURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_DEMOG_DATA.GBL"
let kPersonalInfoCitizenshipURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/UW_SS_MENU.UW_SS_CC_VISA_DOC.GBL"
let kPersonalInfoAbsenceDeclarationURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.UW_SS_CC_ABSENCE.GBL"

private let _sharedClient = QuestClient(baseURL: NSURL(string: ""))

class QuestClient: AFHTTPSessionManager {
    
    var icsid: String = ""
    var currentStateNum: Int = 0
    var currentURLString: String!
    
    var isUndergraduate: Bool = true
    var isLogin: Bool = false
    
    enum PostPage {
        case None
        case PersonalInformation
    }
    var currentPostPage: PostPage = .None
    
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
    
    class var sharedClient: QuestClient {
        return _sharedClient
    }
}

// MARK: Helper methods
extension QuestClient {
    func getHtmlContentFromResponse(response: AnyObject) -> String? {
        let html: String = NSString(data: response as NSData, encoding: NSUTF8StringEncoding)!
        return html
    }
    
    func getICSID(response: AnyObject) -> String? {
        logVerbose()
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
        logVerbose()
        let icsid = getICSID(response)
        if icsid == nil {
            return false
        } else {
            return true
        }
    }
    
    func getStateNum(response: AnyObject) -> Int? {
        logVerbose()
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
    
    func updateState(response: AnyObject) -> Bool {
        logVerbose()
        return updateICSID(response) && updateStateNum(response)
    }
    
    func updateICSID(response: AnyObject) -> Bool{
        logVerbose()
        let icsidString = getICSID(response)
        if icsidString == nil { return false }
        self.icsid = icsidString!
        return true
    }
    
    func updateStateNum(response: AnyObject) -> Bool {
        logVerbose()
        let newNum = getStateNum(response)
        if newNum == nil { return false }
        self.currentStateNum = newNum!
        return true
    }
    
    func isCookieExpired() -> Bool {
        logVerbose()
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
        logVerbose()
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
        logVerbose()
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
    
    func checkIsUndergraduate(response: AnyObject) -> Bool? {
        logVerbose()
        //*/table[@id="ACE_DERIVED_SSS_SCL_SS_ACAD_INFO_LINK"]//*/table[@id="ACE_$ICField280"]//tr//a
        let html = getHtmlContentFromResponse(response)
        if html != nil {
            var elements = html!.searchWithXPathQuery("//*/table[@id='ACE_DERIVED_SSS_SCL_SS_ACAD_INFO_LINK']//*/table[@id='ACE_$ICField280']//tr//a")
            var containUndergrad = elements.filter({
                $0.text().containsSubString("Undergrad")
            })
            if containUndergrad.count > 0 {
                self.isUndergraduate = true
                return true
            } else {
                self.isUndergraduate = false
                return false
            }
        }
        return nil
    }
    
    func getBasicParameters() -> Dictionary<String, String> {
        var newDict = self.basicPostData
        newDict["ICStateNum"] = String(self.currentStateNum)
        newDict["ICSID"] = self.icsid
        return newDict
    }
}

// MARK: Basic operations
extension QuestClient {
    func loginWithUsename(username: String, password: String,
        success: ((response: AnyObject?, json: JSON?) -> ())? = nil,
        failure: ((errorMessage: String, error: NSError) -> ())? = nil)
    {
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
            self.getStudentCenter(success, failure)
        }, failure: { (task, error) -> Void in
            logVerbose("failed: \(error.localizedDescription)")
            failure?(errorMessage: "Login Failed", error: error)
        })
    }
    
    func logout(success: ((response: AnyObject?, json: JSON?) -> ())? = nil,
        failure: ((errorMessgae: String, error: NSError) -> ())? = nil) {
        currentURLString = kQuestLogoutURL
        self.GET(kQuestLogoutURL, parameters: nil, success: { (task, response) -> Void in
            logInfo("Success")
            self.isLogin = false
            success?(response: response, json: nil)
        }, failure: { (task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessgae: "Logout Failed", error: error)
        })
    }
    
    func getStudentCenter(success: ((response: AnyObject?, json: JSON?) -> ())? = nil, failure: ((errorMessage: String, error: NSError) -> ())? = nil) {
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
            if !self.isOnLoginPage(response) {
                if self.pageIsValid(response) {
                    logInfo("isUndergrad: \(self.checkIsUndergraduate(response))")
                    logInfo("ICSID: \(self.getICSID(response)?)")
                    logInfo("StateNum: \(self.getStateNum(response)?)")
                    if self.updateState(response) {
                        success?(response: response, json: nil)
                    } else {
                        failure?(errorMessage: "Update State Failed", error: NSError(domain: "StudentCenter", code: 1003, userInfo: nil))
                    }
                } else {
                    failure?(errorMessage: "Page invalid", error: NSError(domain: "StudentCenter", code: 1002, userInfo: nil))
                }
            } else {
                if self.usernamePasswordInvalid(response) {
                    failure?(errorMessage: "Username/Password invalid", error: NSError(domain: "Login", code: 1000, userInfo: nil))
                } else {
                    failure?(errorMessage: "Unknown", error: NSError(domain: "Login", code: 1001, userInfo: nil))
                }
            }
        }, failure: { (task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessage: "Go to StudentCenter Failed", error: error)
        })
    }
}

// MARK: Personal Information
extension QuestClient {
    func getPersonalInformation(type: PersonalInformationType, success:(data: AnyObject!) -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
        var parameters: Dictionary<String, String>!
        var parseFunction: ((AnyObject) -> JSON?)!
        var successClosure: (response: AnyObject?, json: JSON?) -> () = { (response, json) -> () in
            if json == nil {
                failure(errorMessage: "", error: NSError(domain: "Parse Error", code: 0, userInfo: nil))
            } else {
                success(data: json!.rawValue)
            }
        }
        
        switch type {
        case .Addresses:
            logVerbose(".Addresses")
            parameters = [
                "Page": "SS_ADDRESSES",
                "Action": "C"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoAddressURL, parseAddress, successClosure, failure)
        case .Names:
            logVerbose(".Names")
            parameters = [
                "Page": "SS_CC_NAME",
                "Action": "C"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoNameURL,parseName, successClosure, failure)
        case .PhoneNumbers:
            logVerbose(".Names")
            parameters = [
                "Page": "SS_CC_PERS_PHONE",
                "Action": "U"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoPhoneNumbersURL,parsePhoneNumbers, successClosure, failure)
        case .EmailAddresses:
            break
        case .EmergencyContacts:
            break
        case .DemographicInformation:
            break
        case .CitizenshipImmigrationDocuments:
            break
        default: assert(false, "Wrong PersonalInformation Type")
        }
    }
    
    func postPersonalInformation(success: ((response: AnyObject?, json: JSON?) -> ())? = nil, failure: ((errorMessage: String, error: NSError) -> ())? = nil) {
        logVerbose()
        if currentPostPage == .PersonalInformation {
            success?(response: nil, json: nil)
            return
        }
        var parameters = self.getBasicParameters()
        parameters["ICAction"] = "DERIVED_SSS_SCL_SS_DEMO_SUM_LINK"
        
        self.POST(kStudentCenterURL_HRMS, parameters: parameters, success: { (task, response) -> Void in
            logInfo("Success")
            self.currentPostPage = .PersonalInformation
        }, failure: { (task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessage: "POST Personal Information Failed", error: error)
        })
    }
    
    func getPersonalInformationWithParameters(parameters: Dictionary<String, String>,
        _ urlString: String,
        _ parseFunction: (AnyObject) -> JSON?,
        _ success: ((response: AnyObject?, json: JSON?) -> ())? = nil,
        _ failure: ((errorMessage: String, error: NSError) -> ())? = nil) {
            logVerbose()
            if currentPostPage != .PersonalInformation {
                self.postPersonalInformation(success: { (response, json) -> () in
                    self.getPersonalInformationWithParameters(parameters, urlString, parseFunction,success, failure)
                    }, failure: failure)
            }
            
            self.GET(urlString, parameters: parameters, success: { (task, response) -> Void in
                if self.updateState(response) {
                    logInfo("Success")
                    success?(response: response, json: parseFunction(response))
                } else {
                    failure?(errorMessage: "Update State Failed", error: NSError(domain: "PersonalInformation", code: 1000, userInfo: nil))
                }
                }, failure: {(task, error) -> Void in
                    logError("Failed: \(error.localizedDescription)")
                    failure?(errorMessage: "POST Personal Information Failed", error: error)
            })
    }
    
    /**
    Parse address response to JSON data
    [{"Address Type": "...", "Address": "..."}]
    
    :param: response network response
    
    :returns: JSON data
    */
    func parseAddress(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        let addressElements = html!.searchWithXPathQuery("//*/table[@id='SCC_ADDR_H$scroll$0']//*/table//tr[position()>1]")
        var dataArray = [Dictionary<String, String>]()
        var i = 0
        while i < addressElements.count {
            let eachAddressRow = addressElements[i]
            let columns = eachAddressRow.childrenWithTagName("td")
            if columns.count < 3 { return JSON(dataArray) }
            
            let typeRaw: String = (columns[0] as TFHppleElement).raw
            var type: String? = typeRaw.clearHtmlTags()
            if type == nil { return JSON(dataArray) }
            type = type!.clearNewLines()
            
            let addressRaw: String = (columns[1] as TFHppleElement).raw
            var address: String? = addressRaw.clearHtmlTags()
            if address == nil { return JSON(dataArray) }
            address = address!.clearNewLines()
            
            var addrDict = [
                "Address Type": type!,
                "Address": address!
            ]
            
            dataArray.append(addrDict)
            i++
        }
        return JSON(dataArray)
    }
    
    /**
    Parse address response to JSON data
    {"Message": "...", "Data": [{"Name Type": "...", "Name": "..."}]}
    
    :param: response network response
    
    :returns: JSON data
    */
    func parseName(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        var resultDict: Dictionary<String, AnyObject> = [
            "Message": "",
            "Data": [Dictionary<String, String>]()
        ]
        // Message
        //*[@class="PAPAGEINSTRUCTIONS"]
        let messageElements = html!.searchWithXPathQuery("//*[@class='PAPAGEINSTRUCTIONS']")
        if messageElements.count > 0 {
            let message: String? = (messageElements[0] as TFHppleElement).text()
            if message != nil {
                resultDict["Message"] = message
            }
        }
        
        // Names
        //*[@id="SCC_NAMES_H$scroll$0"]//*/table//tr[position()>1]
        let nameRows = html!.searchWithXPathQuery("//*[@id='SCC_NAMES_H$scroll$0']//*/table//tr[position()>1]")
        var dataArray = [Dictionary<String, String>]()
        var i = 0
        while i < nameRows.count {
            let eachNameRow = nameRows[i]
            let columns = eachNameRow.childrenWithTagName("td")
            if columns.count < 2 { return JSON(resultDict) }
            
            let typeRaw: String = (columns[0] as TFHppleElement).raw
            var type: String? = typeRaw.clearHtmlTags()
            if type == nil { return JSON(resultDict) }
            type = type!.clearNewLines()
            
            let nameRaw: String = (columns[1] as TFHppleElement).raw
            var name: String? = nameRaw.clearHtmlTags()
            if name == nil { return JSON(resultDict) }
            name = name!.clearNewLines()
            
            var nameDict = [
                "Name Type": type!,
                "Name": name!
            ]
            
            dataArray.append(nameDict)
            resultDict["Data"] = dataArray
            i++
        }
        return JSON(resultDict)
    }
    
    /**
    Parse address response to JSON data
    {"Message": "...", "Data": [{"Name Type": "...", "Name": "..."}]}
    
    :param: response network response
    
    :returns: JSON data
    */
    func parsePhoneNumbers(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        var resultDict: Dictionary<String, AnyObject> = [
            "Message": "",
            "Data": [Dictionary<String, String>]()
        ]
        // Message
        //*[@class="PAPAGEINSTRUCTIONS"]
        let messageElements = html!.searchWithXPathQuery("//*[@class='PAPAGEINSTRUCTIONS']")
        if messageElements.count > 0 {
            let message: String? = (messageElements[0] as TFHppleElement).text()
            if message != nil {
                resultDict["Message"] = message
            }
        }
        
        // Names
        //*[@id="SCC_NAMES_H$scroll$0"]//*/table//tr[position()>1]
        let nameRows = html!.searchWithXPathQuery("//*[@id='SCC_NAMES_H$scroll$0']//*/table//tr[position()>1]")
        var dataArray = [Dictionary<String, String>]()
        var i = 0
        while i < nameRows.count {
            let eachNameRow = nameRows[i]
            let columns = eachNameRow.childrenWithTagName("td")
            if columns.count < 2 { return JSON(resultDict) }
            
            let typeRaw: String = (columns[0] as TFHppleElement).raw
            var type: String? = typeRaw.clearHtmlTags()
            if type == nil { return JSON(resultDict) }
            type = type!.clearNewLines()
            
            let nameRaw: String = (columns[1] as TFHppleElement).raw
            var name: String? = nameRaw.clearHtmlTags()
            if name == nil { return JSON(resultDict) }
            name = name!.clearNewLines()
            
            var nameDict = [
                "Name Type": type!,
                "Name": name!
            ]
            
            dataArray.append(nameDict)
            resultDict["Data"] = dataArray
            i++
        }
        return JSON(resultDict)
    }
}