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
                logInfo("AFNetworkReachabilityStatus.Reachable")
                self.operationQueue.suspended = false
                break
            case AFNetworkReachabilityStatus.NotReachable:
                logInfo("AFNetworkReachabilityStatus.NotReachable")
                self.operationQueue.suspended = true
                break
            case AFNetworkReachabilityStatus.Unknown:
                logInfo("AFNetworkReachabilityStatus.Unknown")
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
    func getICSID(html: String) -> String? {
        let element = html.peekAtSearchWithXPathQuery("//*[@id=\"ICSID\"]")
        if element != nil {
            return element!.objectForKey("value")
        }
        return nil
    }
    
    func getStateNum(html: String) -> Int? {
        let element = html.peekAtSearchWithXPathQuery("//*[@id=\"ICStateNum\"]")
        if element != nil {
            return element!.objectForKey("value").toInt()
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
        self.POST(kQuestLoginURL, parameters: parameters, success: { (task, response) -> Void in
            logVerbose("success")
            let html = NSString(data: response as NSData, encoding: NSUTF8StringEncoding)
            self.gotoStudentCenter()
            }) { (task, error) -> Void in
                logVerbose("failed: \(error.localizedDescription)")
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
        
        self.GET(kStudentCenterURL_SA, parameters: parameters, success: { (task, response) -> Void in
            logVerbose("success")
            let html: String = NSString(data: response as NSData, encoding: NSUTF8StringEncoding)!
            logDebug("ICSID: \(self.getICSID(html)?)")
            logDebug("\(self.getStateNum(html)?)")
            }) { (task, error) -> Void in
                logVerbose("failed: \(error.localizedDescription)")
        }
    }
}