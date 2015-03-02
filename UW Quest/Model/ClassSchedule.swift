//
//  MyClassSchedule.swift
//  UW Quest
//
//  Created by Honghao Zhang on 3/2/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import Foundation

class Course {
    var courseNumber: String!
    var courseTitle: String!
    
    var enrollStatus: String!
    var units: String!
    var grading: String!
    var grade: String!
    
    var courseScheduleInformationTable: [[String]]
    var courseScheduleComponentTable: [[String]]!
    
    init(scheduleJson: JSON) {
        courseNumber = scheduleJson["CourseNumber"].stringValue
        courseTitle = scheduleJson["CourseTitle"].stringValue
        
        courseScheduleInformationTable = [[String]]()
        var r = 0
        var c = 0
        for eachRow in scheduleJson["InformationTable"].arrayValue {
            var row = [String]()
            c = 0
            for eachColumn in eachRow.arrayValue {
                row.append(eachColumn.stringValue)
                if r == 1 {
                    switch c {
                    case 0:
                        enrollStatus = eachColumn.stringValue
                    case 1:
                        units = eachColumn.stringValue
                    case 2:
                        grading = eachColumn.stringValue
                    case 3:
                        grade = eachColumn.stringValue
                    default:
                        logError("Extra column")
                    }
                }
                c += 1
            }
            r += 1
            courseScheduleInformationTable.append(row)
        }
        
        courseScheduleComponentTable = [[String]]()
        for eachRow in scheduleJson["ComponentsTable"].arrayValue {
            var row = [String]()
            for eachColumn in eachRow.arrayValue {
                row.append(eachColumn.stringValue)
            }
            courseScheduleComponentTable.append(row)
        }
    }
}

class ClassSchedule {
    var term: String!
    var academicLevel: String!
    var location: String!
    var courses: [Course]!
    
    init(json: JSON) {
        term = json["Term"].stringValue
        academicLevel = json["Level"].stringValue
        location = json["Location"].stringValue
        courses = [Course]()
        for courseJson in json["Courses"].arrayValue {
            var course = Course(scheduleJson: courseJson)
            courses.append(course)
        }
    }
}