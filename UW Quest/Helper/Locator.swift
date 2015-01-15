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
        logVerbose("loginViewController inited")
        var controller: UIViewController = UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController")
        return controller
        }()
    
    lazy var slidingViewController: ECSlidingViewController = {
        logVerbose("slidingViewController inited")
        var controller = UIViewController.viewControllerInStoryboard("MainSlide", viewControllerName: "SlidingViewController") as ECSlidingViewController
        var navigationVC: UINavigationController = UIViewController.viewControllerInStoryboard("MainCollectionViewController", viewControllerName: "MainNavigationViewController") as UINavigationController
        (navigationVC.topViewController as MainCollectionViewController).setup(PersonalInfoImplementation())
        
        controller.topViewController = navigationVC
        controller.anchorRightRevealAmount = 200.0
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
    
    lazy var sharedHud: JGProgressHUD = {
        var hud: JGProgressHUD = JGProgressHUD.prototype()
        return hud
        }()
    
    init() {
        logInfo("Locator inited")
    }
    
    class var sharedLocator: Locator {
        return _sharedLocator
    }
    
    class var sharedQuestClient: QuestClient {
        return QuestClient.sharedClient
    }
}