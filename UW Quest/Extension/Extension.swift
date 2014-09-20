//
//  extensions.swift
//  UW Quest
//
//  Created by Honghao on 9/13/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func colorWithNewAlphaComponent(alpha: CGFloat) -> UIColor {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var oldAplha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &oldAplha)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func getRedComponent() -> CGFloat {
        var red: CGFloat = 0.0
        self.getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    func getGreenComponent() -> CGFloat {
        var green: CGFloat = 0.0
        self.getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    func getBlueComponent() -> CGFloat {
        var blue: CGFloat = 0.0
        self.getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
    
    func getAlphaComponent() -> CGFloat {
        var alpha: CGFloat = 0.0
        self.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
}

extension UIViewController {
    class func viewControllerInStoryboard(storyboardName: String , viewControllerName: String) -> UIViewController {
        var storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerName) as UIViewController
        return viewController
    }
    
    func showHud(title: String) {
        JGProgressHUD.dismiss(0, animated: false)
        // Creat new shared hud
        Locator.sharedLocator.sharedHud = JGProgressHUD.prototype()
        Locator.sharedLocator.sharedHud.textLabel.text = title
        Locator.sharedLocator.sharedHud.showInView(self.view, animated: true)
    }
}

extension JGProgressHUD {
    
    class func prototype() -> JGProgressHUD {
        var hud: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
        let animation: JGProgressHUDFadeZoomAnimation = JGProgressHUDFadeZoomAnimation()
        hud.animation = animation
        hud.interactionType = JGProgressHUDInteractionType.BlockAllTouches
        return hud
    }
    
    class func restore() {
        Locator.sharedLocator.sharedHud.textLabel.text = ""
        Locator.sharedLocator.sharedHud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
    }
    
    class func showSuccess(text: String, duration: NSTimeInterval) {
        // Keep current view
        var currentPresentingView = Locator.sharedLocator.sharedHud.targetView
        // Throw the old hud, make sure the old one is dismissed eventually
        JGProgressHUD.dismiss(0, animated: false)
        // Creat new shared hud
        Locator.sharedLocator.sharedHud = JGProgressHUD.prototype()
        Locator.sharedLocator.sharedHud.textLabel.text = text
        Locator.sharedLocator.sharedHud.indicatorView = JGProgressHUDSuccessIndicatorView()
        Locator.sharedLocator.sharedHud.showInView(currentPresentingView, animated: true)
        JGProgressHUD.dismiss(duration, animated: true)
    }
    
    class func showFailure(text: String, duration: NSTimeInterval) {
        var currentPresentingView = Locator.sharedLocator.sharedHud.targetView
        JGProgressHUD.dismiss(0, animated: false)
        Locator.sharedLocator.sharedHud = JGProgressHUD.prototype()
        Locator.sharedLocator.sharedHud.textLabel.text = text
        Locator.sharedLocator.sharedHud.indicatorView = JGProgressHUDErrorIndicatorView()
        Locator.sharedLocator.sharedHud.showInView(currentPresentingView, animated: true)
        JGProgressHUD.dismiss(duration, animated: true)
    }
    
    // Dismiss current shared HUD
    class func dismiss(delay: NSTimeInterval, animated: Bool) {
        Locator.sharedLocator.sharedHud.dismissAfterDelay(delay, animated: animated)
    }
}
