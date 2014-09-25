//
//  constants.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-15.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

// Colors
let UQMainColor = UQGreenColor
let UQBackgroundColor = UQLightWhiteGrayColor
let UQTextFieldFontColor = UQFontGrayColor
let UQLabelFontColor = UQFontGrayColor
let UQCellBackgroundColor = UIColor(white: 0.90, alpha: 0.9)

let UQBlueColor: UIColor = UIColor(red: 0.22, green: 0.48, blue: 0.69, alpha: 1)

let UQLightBlueColor: UIColor = UIColor(red: 0, green: 0.6, blue: 0.97, alpha: 1)

let UQDarkBlueColor: UIColor = UIColor(red: 0.04, green: 0.11, blue: 0.24, alpha: 1)

let UQGreenColor: UIColor = UIColor(red: 0, green: 0.78, blue: 0.45, alpha: 1)

let UQBlackStoneColor: UIColor = UIColor(red: 0.22, green: 0.25, blue: 0.29, alpha: 1)
    
let UQLightGrayColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
let UQFontGrayColor: UIColor = UIColor(white: 0.3, alpha: 0.9)

let UQLightWhiteGrayColor: UIColor = UIColor(white: 0.95, alpha: 1)

let kBorderColor: UIColor = UQLightGrayColor
let kBorderCornerRadius: CGFloat = 5.0
let kBorderWidth: CGFloat = 1.0

// URLs
let watiamURLString = "https://watiam.uwaterloo.ca/idm/user/login.jsp"
let honghaozURLString = "http://honghaoz.com"
let honghaoLinkedInURLString = "http://ca.linkedin.com/in/honghaozhang"

// Check System Version
let isIOS7: Bool = !isIOS8
let isIOS8: Bool = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1