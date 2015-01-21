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
        var navigationVC: UINavigationController = UIViewController.viewControllerInStoryboard("MainCollectionViewController", viewControllerName: "MainNavigationViewController") as UINavigationController
        (navigationVC.topViewController as MainCollectionViewController).setup(PersonalInfoImplementation())
        
        controller.topViewController = navigationVC
        controller.anchorRightRevealAmount = 200.0
        return controller
    }()
    
    class var slidingViewController: ECSlidingViewController {
        return _sharedLocator._slidingViewController
    }
    
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