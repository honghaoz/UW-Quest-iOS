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
    var courseScheduleInformationTable: [[String]]
    var courseScheduleComponentTable: [[String]]!
    
    init(scheduleJson: JSON) {
        courseNumber = scheduleJson["CourseNumber"].stringValue
        courseTitle = scheduleJson["CourseTitle"].stringValue
        
        courseScheduleInformationTable = [[String]]()
        for eachRow in scheduleJson["InformationTable"].arrayValue {
            var row = [String]()
            for eachColumn in eachRow.arrayValue {
                row.append(eachColumn.stringValue)
            }
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