//
//  QuestClientPersonalInformation.swift
//  UW Quest
//
//  Created by Honghao Zhang on 3/2/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import Foundation

// Personal Information
let kPersonalInfoAddressURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_ADDRESSES.GBL"
let kPersonalInfoNameURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_NAMES.GBL"
let kPersonalInfoPhoneNumbersURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_PERS_PHONE.GBL"
let kPersonalInfoEmailsURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_EMAIL_ADDR.GBL"
let kPersonalInfoEnergencyURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_EMERG_CNTCT.GBL"
let kPersonalInfoDemographicInfoURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.SS_CC_DEMOG_DATA.GBL"
let kPersonalInfoCitizenshipURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/UW_SS_MENU.UW_SS_CC_VISA_DOC.GBL"
let kPersonalInfoAbsenceDeclarationURL = "https://quest.pecs.uwaterloo.ca/psc/SS/ACADEMIC/HRMS/c/CC_PORTFOLIO.UW_SS_CC_ABSENCE.GBL"

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
            logVerbose(".PhoneNumbers")
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
    [{"Address Type": "...", "Address": "..."} ...]
    
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
            
            let typeRaw: String = (columns[0] as! TFHppleElement).raw
            var type: String? = typeRaw.stringByConvertingHTMLToPlainText()
            if type == nil { return JSON(dataArray) }
            //            type = type!.clearNewLines()
            
            let addressRaw: String = (columns[1] as! TFHppleElement).raw
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
            
            let typeRaw: String = (columns[0] as! TFHppleElement).raw
            var type: String? = typeRaw.stringByConvertingHTMLToPlainText()
            if type == nil { return JSON(resultDict) }
            
            let nameRaw: String = (columns[1] as! TFHppleElement).raw
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
    ["Demographic Information": {
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
    }, ...
    ]
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
        
        while html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString1, i) as String) != nil {
            tuples.append(
                [
                    "Type",
                    html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString1, i) as String)!.raw.stringByConvertingHTMLToPlainText().trimmed() + " - " + html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString2, i) as String)!.raw.stringByConvertingHTMLToPlainText().trimmed()
                ]
            )
            tuples.append(
                [
                    "Country",
                    html!.peekAtSearchWithXPathQuery(NSString(format: basicXPathString3, i) as String)!.raw.stringByConvertingHTMLToPlainText().trimmed()
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
    [
    {"Type": "Required Documentation",
    "Data": [
    {
    "Title": "Canada - Student Visa",
    "Date Received": "09/13/2013",
    "Expiration Date": "09/13/2013"
    },
    ...
    ]
    },
    ...
    ]
    
    :param: response response network response
    
    :returns: JSON data
    */
    func parseCitizenship(response: AnyObject) -> JSON? {
        let html = getHtmlContentFromResponse(response)
        if html == nil {
            return nil
        }
        
        var dataArray = [Dictionary<String, AnyObject>]()
        
        //*[@id="win0divVISA_PMT_SUPPRT$0"]
        let basicQueryString: NSString = "//*[@id='win0divVISA_PMT_SUPPRT$%d']//table"
        var i: Int = 0
        var tables = html!.searchWithXPathQuery(NSString(format: basicQueryString, i) as String)
        while tables.count >= 2 {
            var headerTable = tables[0] as TFHppleElement
            
            var docDict = Dictionary<String, AnyObject>()
            // Get header
            var type = headerTable.displayableString()?.trimmed()
            docDict["Type"] = type
            var datas = [Dictionary<String, String>]()
            docDict["Data"] = datas
            
            for x in 1 ..< tables.count {
                var contentTable = tables[x] as TFHppleElement
                // Content
                let contentArray = contentTable.table2DArray()
                if contentArray == nil || contentArray!.count < 2 { return JSON(dataArray) }
                // [["  ", "  ", "Date Received ", "Expiration Date "],
                // ["Canada", "Student Visa", "2013/09/13", "2015/12/31"]]
                // ...
                for j in 1 ..< contentArray!.count {
                    if !(contentArray![0].count == 4) { return JSON(dataArray) }
                    var visaDict = Dictionary<String, String>()
                    visaDict["Title"] = contentArray![j][0] + " - " + contentArray![j][1]
                    visaDict[contentArray![0][2]] = contentArray![j][2]
                    visaDict[contentArray![0][3]] = contentArray![j][3]
                    datas.append(visaDict)
                }
            }
            docDict["Data"] = datas
            dataArray.append(docDict)
            i += 1
            tables = html!.searchWithXPathQuery(NSString(format: basicQueryString, i) as String)
        }
        return JSON(dataArray)
    }
}