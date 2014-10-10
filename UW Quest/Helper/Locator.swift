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
    
    lazy var appDelegate: AppDelegate = {
        var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate
    }()

    // Controllers
    lazy var loginViewController: UIViewController = {
        println("loginViewController inited")
        var controller: UIViewController = UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController")
        return controller
    }()
    
    lazy var slidingViewController: ECSlidingViewController = {
        println("slidingViewController inited")
        var controller = UIViewController.viewControllerInStoryboard("MainSlide", viewControllerName: "SlidingViewController") as ECSlidingViewController
        controller.anchorRightRevealAmount = 150.0
        return controller
        }()
    
    lazy var dynamicTransition: MEDynamicTransition = {
        var dynamicTransition: MEDynamicTransition = MEDynamicTransition()
        return dynamicTransition
        }()
    
    lazy var zoomTransition: MEZoomAnimationController = {
        var zoomTransition: MEZoomAnimationController = MEZoomAnimationController()
        return zoomTransition
        }()
    
    // Shared Instance
    lazy var user: User = {
        return User.sharedUser
    }()
    
    var client: QuestClient = {
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