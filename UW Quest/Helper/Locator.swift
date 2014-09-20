//
//  Locator.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-16.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

private let _sharedLocator = Locator()

class Locator {
    // Controllers
    lazy var tabBarController: UIViewController = {
        println("tabBarController inited")
        var controller: UIViewController = UIViewController.viewControllerInStoryboard("MainTab", viewControllerName: "MainTabBarController")
        return controller
    }()
    
    lazy var loginViewController: UIViewController = {
        println("loginViewController inited")
        var controller: UIViewController = UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController")
        return controller
    }()
    
    // Shared Instance
    lazy var user: User = {
        return User.sharedUser
    }()
    
    lazy var client: QuestClient = {
        return QuestClient.sharedClient
    }()
    
    lazy var sharedHud: JGProgressHUD = {
        var hud: JGProgressHUD = JGProgressHUD.prototype()
        return hud
    }()
    
    init() {
        println("Locator inited")
    }
    
    class var sharedLocator: Locator {
        return _sharedLocator
    }
}