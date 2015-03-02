//
//  QuestClientMyClassSchedule.swift
//  UW Quest
//
//  Created by Honghao Zhang on 3/2/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import Foundation

let kEnrollMyClassScheduleURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/SA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL"
let kEnrollSearchForClassesURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/SA_LEARNER_SERVICES.UW_SSR_CLASS_SRCH.GBL"

// MARK: My Class Schedule
extension QuestClient {
    func postEnroll(success: ((response: AnyObject?, json: JSON?) -> ())? = nil, failure: ((errorMessage: String, error: NSError) -> ())? = nil) {
        logVerbose()
        if currentPostPage == .Enroll {
            success?(response: nil, json: nil)
            return
        }
        var parameters = self.getBasicParameters()
        parameters["ICAction"] = "DERIVED_SSS_SCR_SSS_LINK_ANCHOR2"
        
        self.POST(kStudentCenterURL_HRMS, parameters: parameters, success: { (task, response) -> Void in
            logInfo("Success")
            self.currentPostPage = .Enroll
            }, failure: { (task, error) -> Void in
                logError("Failed: \(error.localizedDescription)")
                failure?(errorMessage: "POST Enroll Failed", error: error)
        })
    }
    
    func getMyClassSchedule(success:(data: AnyObject!) -> (), failure:(errorMessage: String, error: NSError?) -> ()) {
        logVerbose()
        if currentPostPage != .Enroll {
            self.postEnroll(success: { (response, json) -> () in
                self.getMyClassSchedule(success, failure: failure)
            }, failure: failure)
        }
        var parameters = [
            "Page": "SSR_SSENRL_LIST",
            "Action": "A"
        ]
        self.GET(kEnrollMyClassScheduleURL, parameters: parameters, success: { (task, response) -> Void in
            if self.updateState(response) {
                logInfo("Success")
//                success?(response: response, json: parseFunction(response))
            } else {
                failure(errorMessage: "Update State Failed", error: NSError(domain: "Enroll", code: 1000, userInfo: nil))
            }
            }, failure: {(task, error) -> Void in
                logError("Failed: \(error.localizedDescription)")
                failure(errorMessage: "GET Enroll Failed", error: error)
        })
    }
}