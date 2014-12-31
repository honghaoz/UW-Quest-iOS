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

extension UIView {
    
    class func initWithNibName<T>(nibName: String) -> T {
        
        var viewsInNib = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)
        var returnView: T!
        for view in viewsInNib {
            if let view = view as? T {
                returnView = view
                break
            }
        }
        return returnView
    }
    
    func containSubview(view: UIView) -> Bool {
        return self.subviews.filter({$0 as UIView == view}).count > 0
    }
    
    func removeAllSubviews() {
        self.subviews.map({$0.removeFromSuperview})
    }
    
    func addSubviews(views: [UIView]) {
        views.map({self.addSubview($0 as UIView)})
    }
    
    func hideAllSubviews(toHidden: Bool, duration: NSTimeInterval? = 0.25, completion:((Bool) -> Void)? = nil) {
        
        UIView.animateWithDuration(duration!, animations: { () -> Void in
            self.subviews.map({
                ($0 as UIView).alpha = toHidden ? 0.0 : 1.0
            })
            return
            }) { (finished) -> Void in
                self.subviews.map({
                    ($0 as UIView).hidden = toHidden
                })
                completion?(finished)
                return
        }
    }
    
    var blurOverlayViewTagNumber: Int { return 3141592653 }
    
    var blurImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.window!.bounds.size, true, 1)
        self.window!.drawViewHierarchyInRect(self.window!.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let bluredImage = screenshot.applyDarkEffect()
        return bluredImage
    }
    
    func addBlurOverlayView(animated: Bool = false, completion: ((Bool) -> Void)? = nil) {
        var overlayView: UIView!
        if isIOS8 {
            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            overlayView = UIVisualEffectView(effect: blurEffect)
        } else {
            overlayView = UIImageView.newAutoLayoutView()
        }
        
        overlayView.tag = blurOverlayViewTagNumber // Special number for taging this overlayView
        overlayView.alpha = 0
        
        // Setup constraints
        self.addSubview(overlayView!)
        overlayView!.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        overlayView.layoutIfNeeded()
        
        if !isIOS8 {
            (overlayView as UIImageView).image = self.blurImage
        }
        
        if animated {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                overlayView.alpha = 1.0
                }, completion: { finished -> Void in
                    if completion != nil { completion!(finished) }
            })
        } else {
            overlayView.alpha = 1.0
        }
    }
    
    func removeBlurOverlayView(animated: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if let overlayView = self.viewWithTag(blurOverlayViewTagNumber) {
            if animated {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    overlayView.alpha = 0.0
                    }, completion: { finished -> Void in
                        overlayView.removeFromSuperview()
                        if completion != nil { completion!(finished) }
                })
            } else {
                overlayView.removeFromSuperview()
            }
        }
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

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func stretchableImage(color: UIColor) -> UIImage {
        let originalImage = UIImage.imageWithColor(color, size: CGSizeMake(3, 3))
        let insets = UIEdgeInsetsMake(1, 1, 1, 1)
        return originalImage.resizableImageWithCapInsets(insets)
    }
    
    func scaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UINavigationBar {
    func setTransparentBar(animated: Bool = false) {
        let execution: Void -> Void = { Void -> Void in
            self.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.shadowImage = UIImage()
            self.translucent = true
            self.backgroundColor = UIColor.clearColor()
        }
        
        if animated {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                execution()
            })
        } else {
            execution()
        }
    }
    
    func setSolidBar(color: UIColor, animated: Bool = false) {
        let execution: Void -> Void = { Void -> Void in
            self.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.shadowImage = UIImage()
            self.translucent = false
            self.backgroundColor = color
        }
        
        if animated {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                execution()
            })
        } else {
            execution()
        }
    }
}

extension UIFont {
    class func helveticaNenueFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: fontSize)!
    }
    
    class func helveticaNeueLightFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: fontSize)!
    }
    
    class func helveticaNenueThinFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Thin", size: fontSize)!
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
    
    /**
    Check whether childViewControllers contain a view controller
    
    :param: childViewController View controller to be tested
    
    :returns: True if contained, false otherwise
    */
    func containChildViewController(childViewController: UIViewController) -> Bool {
        return self.childViewControllers.filter({$0 as UIViewController == childViewController}).count > 0
    }
    
    func showHud(title: String?) {
        JGProgressHUD.dismiss(0, animated: false)
        // Creat new shared hud
        Locator.sharedLocator.sharedHud = JGProgressHUD.prototype()
        Locator.sharedLocator.sharedHud.textLabel.text = title
        Locator.sharedLocator.sharedHud.showInView(self.view, animated: true)
    }
}

extension NSDateFormatter {
    class func estDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPOSIXLocale
        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")
        return dateFormatter
    }
    
    class func defaultDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPOSIXLocale
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }
}

extension String {
    func searchWithXPathQuery(query: String) -> [TFHppleElement] {
        return (self as NSString).searchWithXPathQuery(query)
    }
    
    func peekAtSearchWithXPathQuery(query: String) -> TFHppleElement? {
        return (self as NSString).peekAtSearchWithXPathQuery(query)
    }
}

extension NSString {
    func searchWithXPathQuery(query: String) -> [TFHppleElement] {
        let htmlData = self.dataUsingEncoding(NSUTF8StringEncoding)
        let doc = TFHpple(HTMLData: htmlData)
        let elements = doc.searchWithXPathQuery(query)
        return elements as [TFHppleElement]
    }
    
    func peekAtSearchWithXPathQuery(query: String) -> TFHppleElement? {
        let htmlData = self.dataUsingEncoding(NSUTF8StringEncoding)
        let doc = TFHpple(HTMLData: htmlData)
        let element = doc.peekAtSearchWithXPathQuery(query)
        return element
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

// Other helpers
infix operator ~= { associativity left precedence 140 }
func ~=(left: CGFloat, right: CGFloat) -> Bool {
    return fabs(left - right) < CGFloat(0.5)
}

func ~=(left: Double, right: Double) -> Bool {
    return fabs(left - right) < Double(0.5)
}

func ~=(left: Float, right: Float) -> Bool {
    return fabs(left - right) < Float(0.5)
}

infix operator !~= { associativity left precedence 140 }
func !~= (left: CGFloat, right: CGFloat) -> Bool {
    return !(left ~= right)
}

func !~=(left: Double, right: Double) -> Bool {
    return !(left ~= right)
}

func !~=(left: Float, right: Float) -> Bool {
    return !(left ~= right)
}

//
func CGFloatMax(a: CGFloat, b: CGFloat) -> CGFloat {
    return CGFloat(fmaxf(Float(a), Float(b)))
}

func CGFloatMin(a: CGFloat, b: CGFloat) -> CGFloat {
    return CGFloat(fminf(Float(a), Float(b)))
}

extension CGFloat {
    /// Get a radian degree
    var radianDegree: CGFloat {
        return CGFloat(M_PI / 180) * self
    }
}

extension Double {
    var dispatchTime: dispatch_time_t {
        get {
            return dispatch_time(DISPATCH_TIME_NOW,Int64(self * Double(NSEC_PER_SEC)))
        }
    }
}

// MARK: Device Related

// Check System Version

var isIOS7: Bool = !isIOS8
var isIOS8: Bool = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1

var screenWidth: CGFloat { return UIScreen.mainScreen().bounds.size.width }
var screenHeight: CGFloat { return UIScreen.mainScreen().bounds.size.height }

var screenSize: CGSize { return UIScreen.mainScreen().bounds.size }
var screenBounds: CGRect { return UIScreen.mainScreen().bounds }

var isIpad: Bool { return UIDevice.currentDevice().userInterfaceIdiom == .Pad }

var is3_5InchScreen: Bool { return screenHeight ~= 480.0 }
var is4InchScreen: Bool { return screenHeight ~= 568.0 }
var isIphone6: Bool { return screenHeight ~= 667.0 }
var isIphone6Plus: Bool { return screenHeight ~= 736.0 }

//
var keyWindow: UIWindow { return UIApplication.sharedApplication().keyWindow! }

// Debug Helpers

func addShadow(view: UIView) {
    let shadowPath = UIBezierPath(rect: view.bounds)
    view.layer.masksToBounds = false;
    view.layer.shadowColor = UIColor.blackColor().CGColor;
    view.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowPath = shadowPath.CGPath;
}
