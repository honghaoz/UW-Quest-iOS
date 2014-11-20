//
//  MyAcademics.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-11-05.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

enum MyAcademicsType: String {
    case MyProgram = "My Program"
    case Grades = "Names"
    case UnofficialTranscript = "Phone Numbers"
    case MyAdvisors = "Email Addresses"
    
    static let allValues = [MyProgram.rawValue, Grades.rawValue, UnofficialTranscript.rawValue, MyAdvisors.rawValue]
}