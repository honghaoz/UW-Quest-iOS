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
    
    class var sharedLocator: Locator {
        return _sharedLocator
    }
    
    // Controllers
    private lazy var _loginViewController: UIViewController = {
        logVerbose("loginViewController inited")
        var controller: UIViewController = UIViewController.viewControllerInStoryboard("Login", viewControllerName: "LoginViewController")
        return controller
    }()
    
    class var loginViewController: UIViewController {
        return _sharedLocator._loginViewController
    }
    
    private lazy var _slidingViewController: ECSlidingViewController = {
        logVerbose("slidingViewController inited")
        var controller = UIViewController.viewControllerInStoryboard("MainSlide", viewControllerName: "SlidingViewController") as ECSlidingViewController
        
        controller.topViewController = Locator.personalInformationNavigationViewController
        controller.anchorRightRevealAmount = 200.0
        return controller
    }()
    
    class var slidingViewController: ECSlidingViewController {
        return _sharedLocator._slidingViewController
    }
    
    // MARK: Personal Information
    private lazy var _personalInformationNavigationViewController: UINavigationController = {
        var navigationVC = UIViewController.viewControllerInStoryboard("MainCollectionViewController", viewControllerName: "MainNavigationViewController") as UINavigationController
        (navigationVC.topViewController as MainCollectionViewController).setup(PersonalInfoImplementation())
        return navigationVC
    }()
    
    class var personalInformationNavigationViewController: UINavigationController {
        return _sharedLocator._personalInformationNavigationViewController
    }
    
    // MARK: Search for Classes
    private lazy var _searchClassNavigationViewController: UINavigationController = {
        return UIViewController.viewControllerInStoryboard("SearchClass", viewControllerName: "SearchClassNavigationViewController") as UINavigationController
    }()
    
    class var searchClassNavigationViewController: UINavigationController {
        return _sharedLocator._searchClassNavigationViewController
    }
    
    // MARK: My Classes Schedule
    private lazy var _myClassScheduleNavigationViewController: UINavigationController = {
        return UIViewController.viewControllerInStoryboard("MyClassSchedule", viewControllerName: "MyClassScheduleNavigationViewController") as UINavigationController
        }()
    
    class var myClassScheduleNavigationViewController: UINavigationController {
        return _sharedLocator._myClassScheduleNavigationViewController
    }
    
    // MARK:
    
    lazy var dynamicTransition: MEDynamicTransition = {
        var dynamicTransition: MEDynamicTransition = MEDynamicTransition()
        return dynamicTransition
    }()
    
    lazy var zoomTransition: MEZoomAnimationController = {
        var zoomTransition: MEZoomAnimationController = MEZoomAnimationController()
        return zoomTransition
    }()
    
    // Shared Instance
    lazy var _user: User = {
        return User.sharedUser
    }()
    
    class var user: User { return _sharedLocator._user }
    
    class var sharedQuestClient: QuestClient {
        return QuestClient.sharedClient
    }
    
    // UIs
    lazy var sharedHud: JGProgressHUD = {
        var hud: JGProgressHUD = JGProgressHUD.prototype()
        return hud
    }()
}