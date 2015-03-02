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
            self.currentStateNum += 1
            self.currentPostPage = .Enroll
            success?(response: response, json: nil)
        }, failure: { (task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessage: "POST Enroll Failed", error: error)
        })
    }
    
    // This method may get list of terms or current schedule directly
    func getMyClassSchedule(success:((response: AnyObject?, json: JSON?) -> ())? = nil, failure:((errorMessage: String, error: NSError) -> ())? = nil) {
        logVerbose()
        if currentPostPage != .Enroll {
            self.postEnroll(success: { (response, json) -> () in
                self.getMyClassSchedule(success: success, failure: failure)
            }, failure: failure)
            return
        }
        var parameters = [
            "Page": "SSR_SSENRL_LIST",
            "Action": "A"
        ]
        self.GET(kEnrollMyClassScheduleURL, parameters: parameters, success: { (task, response) -> Void in
            if self.updateState(response) {
                logInfo("Success")
                success?(response: response, json: nil) // FIXME:
            } else {
                logError("Update State Failed")
                failure?(errorMessage: "Update State Failed", error: NSError(domain: "Enroll", code: 1000, userInfo: nil))
            }
        }, failure: {(task, error) -> Void in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessage: "GET Enroll Failed", error: error)
        })
    }
    
    func postMyClassScheduleWithIndex(index: Int, success:((response: AnyObject?, json: JSON?) -> ())? = nil, failure:((errorMessage: String, error: NSError) -> ())? = nil) {
        logVerbose()
        if currentPostPage != .Enroll {
            self.postEnroll(success: { (response, json) -> () in
                self.postMyClassScheduleWithIndex(index, success: success, failure: failure)
                }, failure: failure)
            return
        }
        
        self.getMyClassSchedule(success: { (response, json) -> () in
            var parameters = self.getBasicParameters()
            parameters["ICAction"] = "DERIVED_SSS_SCT_SSR_PB_GO"
            parameters["DERIVED_SSTSNAV_SSTS_MAIN_GOTO$7$"] = "9999"
            parameters["SSR_DUMMY_RECV1$sels$0"] = String(index)
            parameters["DERIVED_SSTSNAV_SSTS_MAIN_GOTO$8$"] = "9999"
            
            self.POST(kEnrollMyClassScheduleURL, parameters: parameters, success: { (task, response) -> Void in
                logInfo("Success")
                self.currentStateNum += 1
                self.currentPostPage = .Enroll
                success?(response: response, json: self.parseMyClassSchedule(response))
            }, failure: { (task, error) -> Void in
                logError("Failed: \(error.localizedDescription)")
                failure?(errorMessage: "POST My Class Schedule Term Failed", error: error)
            })
        }, failure: { (errorMessage, error) -> () in
            logError("Failed: \(error.localizedDescription)")
            failure?(errorMessage: "POST My Class Schedule Term Failed", error: error)
        })
    }
    
    /**
    JSON 
    {
        "Term": "Winter 2015",
        "Level": "Graduate",
        "Location": "University of Waterloo",
        "Courses": [
            {
                "CourseNumber": "CS 686"
                "CourseTitle": "Intro Artificial Intelligence"
                ////////////////////////////////////
                "InformationTable": [["Status", "Units", "Grading", "Grade"], ["Enrolled", "0.50", "Numeric Grading Basis", ""]]
                "ComponentsTable": [["Class Nbr", "Section", "Component", "Days & Times", "Room", "Instructor", "Start/End Date"], ["5711", "001", "LEC", "TTh 11:30AM - 12:50PM", "PHY   313", "Kate Larson", "2015/01/05 - 2015/04/06"]]
                ///////////////////////////////////
            }
        ]
    }
    */
    func parseMyClassSchedule(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        var resultDict = Dictionary<String, AnyObject>()
        
        // Header text
        //*[@id="DERIVED_REGFRM1_SSR_STDNTKEY_DESCR$5$"]
        let headerElement = html!.searchWithXPathQuery("//*[@id='DERIVED_REGFRM1_SSR_STDNTKEY_DESCR$5$']")
        if headerElement.count > 0 {
            if let titleText = (headerElement[0] as TFHppleElement).text() {
                let headers = (titleText as NSString).componentsSeparatedByString("|")
                if headers.count == 3 {
                    resultDict["Term"] = (headers[0] as! String).trimmed()
                    resultDict["Level"] = (headers[1] as! String).trimmed()
                    resultDict["Location"] = (headers[2] as! String).trimmed()
                } else {
                    //
                }
            }
        } else {
            //
        }
        
        var coursesArray = [Dictionary<String, AnyObject>]()
        // Courses
        //*[@id="ACE_STDNT_ENRL_SSV2$0"]
        let scheduleTables = html!.searchWithXPathQuery("//*[@id='ACE_STDNT_ENRL_SSV2$0']")
        if scheduleTables.count == 1 {
            let schedule = scheduleTables[0] as TFHppleElement
            var i = 0
            while true {
                //*[@id="win0divDERIVED_REGFRM1_DESCR20$0"]
                let courseDivs = schedule.searchWithXPathQuery("//*[@id='win0divDERIVED_REGFRM1_DESCR20$\(i)']")
                if courseDivs.count > 0 {
                    var courseDict = Dictionary<String, AnyObject>()
                    let courseDiv = courseDivs[0] as TFHppleElement
                    
                    // Title
                    //*[@id="win0divDERIVED_REGFRM1_DESCR20$0"]/table/tbody/tr[1]/td
                    let titleText = courseDiv.firstChildWithTagName("table").firstChildWithTagName("tr").firstChildWithTagName("td").displayableString()!
                    var components = (titleText as NSString).componentsSeparatedByString("-")
                    if components.count == 2 {
                        courseDict["CourseNumber"] = (components[0] as! String).trimmed()
                        courseDict["CourseTitle"] = (components[1] as! String).trimmed()
                    } else {
                        //
                    }
                    
                    // Info
                    //*[@id="win0divSSR_DUMMY_RECVW$0"]
                    //*[@id="SSR_DUMMY_RECVW$scroll$0"]
                    let infomationElements = courseDiv.searchWithXPathQuery("//*[@id='SSR_DUMMY_RECVW$scroll$\(i)']")
                    if infomationElements.count > 0 {
                        let infoTable = infomationElements[0].table2DArray()
//                        logDebug("\(infoTable)")
                        courseDict["InformationTable"] = infoTable
                    } else {
                        //
                    }
                    
                    // Component
                    //*[@id="CLASS_MTG_VW$scroll$0"]
                    //*[@id="CLASS_MTG_VW$scroll$1"]
                    let componentElements = courseDiv.searchWithXPathQuery("//*[@id='CLASS_MTG_VW$scroll$\(i)']")
                    if componentElements.count > 0 {
                        let componentTable = componentElements[0].table2DArray()
//                        logDebug("\(componentTable)")
                        courseDict["ComponentsTable"] = componentTable
                    } else {
                        //
                    }
                    coursesArray.append(courseDict)
                } else {
                    break
                }
                i += 1
            }
        } else {
            //
        }
        resultDict["Courses"] = coursesArray
        logDebug("\(resultDict)")
        
        return JSON(resultDict)
    }
}