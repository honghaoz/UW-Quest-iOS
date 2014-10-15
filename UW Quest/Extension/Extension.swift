//
//  Extension.swift
//  UW Quest
//
//  Created by Honghao on 9/13/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /**
    Get a UIColor with same RGB values but specified Alpha value
    
    :param: alpha New alpha value
    
    :returns: New UIColor instance
    */
    func colorWithNewAlphaComponent(alpha: CGFloat) -> UIColor {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var oldAplha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &oldAplha)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
    Get R component from this UIColor
    
    :returns: Red value
    */
    func getRedComponent() -> CGFloat {
        var red: CGFloat = 0.0
        self.getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    /**
    Get G component from this UIColor
    
    :returns: Green value
    */
    func getGreenComponent() -> CGFloat {
        var green: CGFloat = 0.0
        self.getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    /**
    Get B component from this UIColor
    
    :returns: Blue value
    */
    func getBlueComponent() -> CGFloat {
        var blue: CGFloat = 0.0
        self.getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
    
    /**
    Get Alpha component from this UIColor
    
    :returns: Alpha value
    */
    func getAlphaComponent() -> CGFloat {
        var alpha: CGFloat = 0.0
        self.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
}

extension UIViewController {
    /**
    Initialize a view controller in storyboard
    
    :param: storyboardName     Storyboard name
    :param: viewControllerName Storyboard ID of the view controller
    
    :returns: An instance of view controller
    */
    class func viewControllerInStoryboard(storyboardName: String , viewControllerName: String) -> UIViewController {
        var storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerName) as UIViewController
        return viewController
    }
    
    func showHud(title: String?) {
        JGProgressHUD.dismiss(0, animated: false)
        // Creat new shared hud
        Locator.sharedLocator.sharedHud = JGProgressHUD.prototype()
        Locator.sharedLocator.sharedHud.textLabel.text = title
        Locator.sharedLocator.sharedHud.showInView(self.view, animated: true)
    }
}

extension JGProgressHUD {
    
    class func prototype() -> JGProgressHUD {
        var hud: JGProgressHUD = JGProgressHUD(style: isIOS7 ? JGProgressHUDStyle.ExtraLight :
            JGProgressHUDStyle.Light)
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

extension UILabel {
    /**
    Get exact size for UILabel, computed with text and font on this label
    
    :returns: CGSize for this label
    */
    func exactSize() -> CGSize {
        let text: NSString = self.text!
        var newSize = text.sizeWithAttributes([NSFontAttributeName: self.font])
        newSize.width = ceil(newSize.width)
        newSize.height = ceil(newSize.height)
        return newSize
    }
}

// Debug Helpers
func logMethod(_ logMessage: String? = nil, functionName: String = __FUNCTION__) {
    if let realLogMessage = logMessage {
        println("\(functionName): \(logMessage)")
    }
    else {
        println("\(functionName)")
    }
}

func addShadow(view: UIView) {
    let shadowPath = UIBezierPath(rect: view.bounds)
    view.layer.masksToBounds = false;
    view.layer.shadowColor = UIColor.blackColor().CGColor;
    view.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowPath = shadowPath.CGPath;
}
