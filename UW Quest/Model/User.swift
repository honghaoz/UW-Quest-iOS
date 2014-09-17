//
//  User.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-15.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

private let _sharedUser = User()

class User {
    var userName: String = ""
    var password: String = ""
    var isRemembered: Bool = true
    var isLoggedIn: Bool = false
    
    init() {
        println("User inited")
    }
    
    class var sharedUser: User {
        return _sharedUser
    }
}