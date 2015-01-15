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
                failure(errorMessage: "Parse Error", error: NSError(domain: "Parse Error", code: 0, userInfo: nil))
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
            getPersonalInformationWithParameters(parameters, kPersonalInfoPhoneNumbersURL, parsePhoneNumbers, successClosure, failure)
        case .EmailAddresses:
            logVerbose(".Emails")
            parameters = [
                "Page": "SS_CC_EMAIL_ADDR",
                "Action": "U"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoEmailsURL, parseEmails, successClosure, failure)
        case .EmergencyContacts:
            logVerbose(".EmergencyContacts")
            parameters = [
                "Page": "SS_CC_EMRG_CNTCT_L",
                "Action": "U"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoEnergencyURL, parseEmergencyContacts, successClosure, failure)
        case .DemographicInformation:
            logVerbose(".DemographicInformation")
            parameters = [
                "Page": "SS_CC_DEMOG_DATA",
                "Action": "U"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoDemographicInfoURL, parseDemographicInfo, successClosure, failure)
        case .CitizenshipImmigrationDocuments:
            logVerbose(".CitizenshipImmigrationDocuments")
            parameters = [
                "Page": "UW_SS_CC_VISA_DOC",
                "Action": "U"
            ]
            getPersonalInformationWithParameters(parameters, kPersonalInfoCitizenshipURL, parseCitizenship, successClosure, failure)
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
            var type: String? = typeRaw.stringByConvertingHTMLToPlainText()
            if type == nil { return JSON(dataArray) }
//            type = type!.clearNewLines()
            
            let addressRaw: String = (columns[1] as TFHppleElement).raw
            var address: String? = addressRaw.stringByConvertingHTMLToPlainText()
            if address == nil { return JSON(dataArray) }
//            address = address!.clearNewLines()
            
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
            var type: String? = typeRaw.stringByConvertingHTMLToPlainText()
            if type == nil { return JSON(resultDict) }
            
            let nameRaw: String = (columns[1] as TFHppleElement).raw
            var name: String? = nameRaw.stringByConvertingHTMLToPlainText()
            if name == nil { return JSON(resultDict) }
            
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
    [{"Phone Type": "Business", "Telephone": "519/781-2862", "Ext": "", "Country": "001", "Preferred": "Y"}]
    
    :param: response network response
    
    :returns: JSON data
    */
    func parsePhoneNumbers(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        
        // Phone number table
        let phoneTables = html!.searchWithXPathQuery("//*[@id='SCC_PERS_PHN_H$scroll$0']")
        if phoneTables.count == 0 {
            return JSON([])
        } else {
            let phoneTable = phoneTables[0] as TFHppleElement
            let tableArray = phoneTable.table2DArray()
            var dataArray = [Dictionary<String, String>]()
            if tableArray != nil {
                for i in 1 ..< tableArray!.count {
                    var dict = Dictionary<String, String>()
                    for j in 0 ..< 5 {
                        dict[tableArray![0][j]] = tableArray![i][j]
                    }
                    dataArray.append(dict)
                }
            }
            return JSON(dataArray)
        }
    }
    
    /**
    Parse email address response to JSON data
    {
        'alternate_email_address': {
            'data': [{'email_address': 'zhh358@gmail.com',
                        'email_type': 'Home'}
                        ],
            'description': 'The Admissions Office will use the Home email address to communicate with you as an applicant.'
            },
        'description': 'Email is the primary means of communication used by the University. It is important for you to keep your email address up to date.',
        'campus_email_address': {
            'data': [{'delivered_to': 'h344zhan@connect.uwaterloo.ca',
                        'campus_email': 'h344zhan@uwaterloo.ca'}
                        ],
            'description': 'This is the official email address the University community will use to communicate with you as a student.'}
    }
    
    :param: response network response
    
    :returns: JSON data
    */
    func parseEmails(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        
        var responseDictionary = [String: AnyObject]()
        
        // Description
        let descriptionElements = html!.searchWithXPathQuery("//*[@id='win0div$ICField55']")
        if descriptionElements.count == 0 {
            responseDictionary["description"] = ""
        } else {
            responseDictionary["description"] = descriptionElements[0].raw.stringByConvertingHTMLToPlainText()
        }
        
        // Campus email
        var campusEmailDict = [String: AnyObject]()
        let campusDescriptionElements = html!.searchWithXPathQuery("//*[@id='win0div$ICField59']")
        if campusDescriptionElements.count == 0 {
            campusEmailDict["description"] = ""
        } else {
            campusEmailDict["description"] = campusDescriptionElements[0].raw.stringByConvertingHTMLToPlainText()
        }
        
        var dataArray = [Dictionary<String, String>]()
        let campusEmailTableElements = html!.searchWithXPathQuery("//*[@id='win0divUW_RTG_EMAIL_VW$0']")
        if campusEmailTableElements.count > 0 {
            let tableArray = campusEmailTableElements[0].table2DArray()
            if tableArray != nil {
                for i in 1 ..< tableArray!.count {
                    var dict = Dictionary<String, String>()
                    for j in 0 ..< 2 {
                        dict[tableArray![0][j]] = tableArray![i][j]
                    }
                    dataArray.append(dict)
                }
            }
        }
        campusEmailDict["data"] = dataArray
        responseDictionary["campus_email_address"] = campusEmailDict
        
        
        // Alternative email
        var alterEmailDict = [String: AnyObject]()
        let alterDescriptionElements = html!.searchWithXPathQuery("//*[@id='win0div$ICField72']")
        if alterDescriptionElements.count == 0 {
            alterEmailDict["description"] = ""
        } else {
            alterEmailDict["description"] = alterDescriptionElements[0].raw.stringByConvertingHTMLToPlainText()
        }
        
        dataArray = [Dictionary<String, String>]()
        let alterEmailTableElements = html!.searchWithXPathQuery("//*[@id='win0divSCC_EMAIL_H$0']")
        if alterEmailTableElements.count > 0 {
            let tableArray = alterEmailTableElements[0].table2DArray()
            if tableArray != nil {
                for i in 1 ..< tableArray!.count {
                    var dict = Dictionary<String, String>()
                    for j in 0 ..< 2 {
                        dict[tableArray![0][j]] = tableArray![i][j]
                    }
                    dataArray.append(dict)
                }
            }
        }
        alterEmailDict["data"] = dataArray
        responseDictionary["alternate_email_address"] = alterEmailDict
        return JSON(responseDictionary)
    }
    
    /**
    [{'relationship': 'Friend', 'extension': '-', 'country': '001', 'phone': '519/781-2862', 'primary_contact': u'Y', 'contact_name': 'Wenchao Wang'}, 
    
     {'relationship': 'Other', 'extension': '-', 'country': '001', 'phone': '519/781-2862', 'primary_contact': u'N', 'contact_name': 'Yansong Li'}
    ]
    
    :param: response response network response
    
    :returns: JSON data
    */
    func parseEmergencyContacts(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        
        //*[@id="win0divSCC_EMERG_CNT_H$0"]
        let tables = html!.searchWithXPathQuery("//*[@id='win0divSCC_EMERG_CNT_H$0']")
        if tables.count == 0 {
            return JSON([])
        } else {
            let contactTable = tables[0] as TFHppleElement
            let tableArray = contactTable.table2DArray()
            var dataArray = [Dictionary<String, String>]()
            if tableArray != nil {
                for i in 1 ..< tableArray!.count {
                    var dict = Dictionary<String, String>()
                    for j in 0 ..< 6 {
                        dict[tableArray![0][j]] = tableArray![i][j]
                    }
                    dataArray.append(dict)
                }
            }
            return JSON(dataArray)
        }
    }
    
    /**
    {"Demographic Information": {
        "ID": "11111111"
        "Gender": "Male"
        Date of Birth: 01/01/1900
        Birth Country: ""
        Birth State: ""
        Marital Status: Single
        Military Status: ""
    },
    "National Identification Number": {
        Country: Canada
        National ID Type: SIN
        National ID
    },
    "Ethnicity": {
        Ethnic Group: ""
        Description: ""
        Primary: ""
    },
    "Citizenship Information": {
        Description Student Permit
        Country Canada
        Description Citizen
        Country China
    }
    "Driver's License": {
        License #
        Country
        State
    }
    Visa or Permit Data: {
        *Type: Student Visa - Visa
        Country: Canada
    },
    "message": "If any of the information above is wrong, contact your administrative office."
    
    :param: response response network response
    
    :returns: JSON data
    */
    func parseDemographicInfo(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        
        var responseDictionary = [String: AnyObject]()
        
        // Demographic
        //*[@id="ACE_$ICField45"]
        var tables = html!.searchWithXPathQuery("//*[@id='ACE_$ICField45']")
        if tables.count == 0 {
            return JSON(responseDictionary)
        } else {
            var demoTuples = [[String]]()
            let demoTable = tables[0] as TFHppleElement
            let tableArray = demoTable.table2DArray()
            if tableArray != nil {
                var oneDArray = transform2dTo1d(tableArray!)
                var i: Int = 0
                while i < oneDArray.count {
                    let t = [oneDArray[i], oneDArray[i + 1]]
                    demoTuples.append(t)
                    i += 2
                }
            }
            responseDictionary["Demographic Information"] = demoTuples
        }
        
        // National Identification Number
        //*[@id="ACE_$ICField1$0"]
        tables = html!.searchWithXPathQuery("//*[@id='ACE_$ICField1$0']")
        if tables.count == 0 {
            return JSON(responseDictionary)
        } else {
            let table = tables[0] as TFHppleElement
            let tableArray = table.table2DArray()
            var tuples = [[String]]()
            if tableArray != nil {
                // [["", "", "", "", "", "", ""], ["", "Country", "National ID Type", "National ID"], ["", "Canada", "SIN", " "]]
                for i in 2 ..< tableArray!.count {
                    for j in 1 ..< tableArray![i].count {
                        tuples.append([tableArray![1][j], tableArray![i][j]])
                    }
                }
            }
            responseDictionary["National Identification Number"] = tuples
        }
        
        // Ethnicity
        //*[@id="ACE_ETHNICITY$0"]
        tables = html!.searchWithXPathQuery("//*[@id='ACE_ETHNICITY$0']")
        if tables.count == 0 {
            return JSON(responseDictionary)
        } else {
            let table = tables[0] as TFHppleElement
            let tableArray = table.table2DArray()
            var tuples = [[String]]()
            if tableArray != nil {
                // [["", "", "", "", "", "", ""], ["", "Ethnic Group", "Description", "Primary"], ["", " ", " ", " "]]
                for i in 2 ..< tableArray!.count {
                    for j in 1 ..< tableArray![i].count {
                        tuples.append([tableArray![1][j], tableArray![i][j]])
                    }
                }
            }
            responseDictionary["Ethnicity"] = tuples
        }
        
        // Citizenship Information
        //*[@id="ACE_CITIZENSHIP$0"]
        tables = html!.searchWithXPathQuery("//*[@id='ACE_CITIZENSHIP$0']")
        if tables.count == 0 {
            return JSON(responseDictionary)
        } else {
            let table = tables[0] as TFHppleElement
            let tableArray = table.table2DArray()
            // [["", "", "", "", ""],
            // ["", "Description", "", "Country"], 
            // ["", "Student Permit"], 
            // ["", "Canada"], 
            // ["", "Description", "Country"], 
            // ["", "Citizen"], 
            // ["", "China"]]
            var tuples = [[String]]()
            if tableArray != nil {
                var i: Int = 2
                while i < tableArray!.count {
                    tuples.append([tableArray![i][1], tableArray![i + 1][1]])
                    i += 3
                }
            }
            responseDictionary["Citizenship Information"] = tuples
        }
        
        // Driver's License
        //*[@id="ACE_DRIVERS_LIC$0"]
        
        //*[@id="win0divDRIVERS_LIC_VW_DRIVERS_LIC_NBRlbl$0"]
        //*[@id="win0divDRIVERS_LIC_VW_DRIVERS_LIC_NBR$0"]
        
        //*[@id="win0divCOUNTRY_TBL_DESCR$28$lbl$0"]
        //*[@id="win0divCOUNTRY_TBL_DESCR$28$$0"]
        
        //*[@id="win0divDRIVERS_LIC_VW_STATElbl$0"]
        //*[@id="win0divDRIVERS_LIC_VW_STATE$0"]
        var tuples = [[String]]()
        tuples.append(
            [
                html!.plainTextForXPathQuery("//*[@id='win0divDRIVERS_LIC_VW_DRIVERS_LIC_NBRlbl$0']"),
                html!.plainTextForXPathQuery("//*[@id='win0divDRIVERS_LIC_VW_DRIVERS_LIC_NBR$0']")
            ]
        )
        
        tuples.append(
            [
                html!.plainTextForXPathQuery("//*[@id='win0divCOUNTRY_TBL_DESCR$28$lbl$0']"),
                html!.plainTextForXPathQuery("//*[@id='win0divCOUNTRY_TBL_DESCR$28$$0']")
            ]
        )
        
        tuples.append(
            [
                html!.plainTextForXPathQuery("//*[@id='win0divDRIVERS_LIC_VW_STATElbl$0']"),
                html!.plainTextForXPathQuery("//*[@id='win0divDRIVERS_LIC_VW_STATE$0']")
            ]
        )
        
        responseDictionary["Driver's License"] = tuples
        
        // Visa or Permit Data
        //*[@id="VISA_PERMIT_TBL_DESCR$0"]
        //*[@id="PSXLATITEM_XLATLONGNAME$36$$0"]
        //*[@id="COUNTRY_TBL_DESCR$32$$0"]
        
        tuples = [[String]]()
        var i: Int = 0
        var basicXPathString1: NSString = "//*[@id='VISA_PERMIT_TBL_DESCR$%d']"
        var basicXPathString2: NSString = "//*[@id='PSXLATITEM_XLATLONGNAME$36$$%d']"
        var basicXPathString3: NSString = "//*[@id='COUNTRY_TBL_DESCR$32$$%d']"
        
        while html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString1, i)) != nil {
            tuples.append(
                [
                    "Type",
                    html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString1, i))!.raw.stringByConvertingHTMLToPlainText().trimmed() + " - " + html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString2, i))!.raw.stringByConvertingHTMLToPlainText().trimmed()
                ]
            )
            tuples.append(
                [
                    "Country",
                    html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString3, i))!.raw.stringByConvertingHTMLToPlainText().trimmed()
                ]
            )
            i += 1
        }
        
        responseDictionary["Visa or Permit Data"] = tuples
        
        // Message
        //*[@id="win0div$ICField37"]
        responseDictionary["Message"] = html!.plainTextForXPathQuery("//*[@id='win0div$ICField37']")
        return JSON(responseDictionary)
    }
    
    /**
    {"Required Documentation": {
    
    }
    
    :param: response response network response
    
    :returns: JSON data
    */
    func parseCitizenship(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        return nil
    }
}

// MARK: Helpers
extension QuestClient {
    func transform2dTo1d(twoDArray: [[String]]) -> [String] {
        var oneDArray = [String]()
        for row in twoDArray {
            for col in row {
                if col.length > 0 {
                    oneDArray.append(col)
                }
            }
        }
        return oneDArray
    }
}