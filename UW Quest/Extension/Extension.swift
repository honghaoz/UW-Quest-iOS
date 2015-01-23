//
//  Extension.swift
//  UW Quest
//
//  Created by Honghao on 9/13/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

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
        self.subviews.map({$0.removeFromSuperview()})
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
        overlayView.clipsToBounds = self.clipsToBounds
        overlayView.layer.cornerRadius = self.layer.cornerRadius
        
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
    
    func autoSetContentCompressionResistanceRequiredForAixs(axis: ALAxis) {
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            self.autoSetContentCompressionResistancePriorityForAxis(axis)
        })
    }
    
    func autoSetContentHuggingResistanceRequiredForAixs(axis: ALAxis) {
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            self.autoSetContentHuggingPriorityForAxis(axis)
        })
    }
    
    func autoSetContentCompressionResistanceRequired() {
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            self.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            self.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
        })
    }
    
    func autoSetContentHuggingResistanceRequired() {
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            self.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
            self.autoSetContentHuggingPriorityForAxis(ALAxis.Horizontal)
        })
    }
    
    func autoSetContentCompressionHuggingResistanceRequired() {
        UIView.autoSetPriority(1000, forConstraints: { () -> Void in
            self.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Vertical)
            self.autoSetContentCompressionResistancePriorityForAxis(ALAxis.Horizontal)
            self.autoSetContentHuggingPriorityForAxis(ALAxis.Vertical)
            self.autoSetContentHuggingPriorityForAxis(ALAxis.Horizontal)
        })
    }
    
    var copy: UIView {
        var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
        var copy: UIView = NSKeyedUnarchiver.unarchiveObjectWithData(data) as UIView
        return copy
    }
}

extension UINib {
    var copy: UINib {
        var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
        var copy: UINib = NSKeyedUnarchiver.unarchiveObjectWithData(data) as UINib
        return copy
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

extension UICollectionView {
    enum DequeueCellFunctionType {
        case SizeFor
        case CellFor
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
    
    func containsSubString(substring: String) -> Bool {
        return (self as NSString).containsSubString(substring)
    }
    
    func replacePattern(pattern: String, withString: String) -> String? {
        var error: NSError? = nil
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(0), error: &error)
        let newString = regex?.stringByReplacingMatchesInString(self, options: NSMatchingOptions(0), range: NSMakeRange(0, self.length), withTemplate: withString)
        return newString
    }
    
    func plainTextForXPathQuery(query: String) -> String {
        return (self as NSString).plainTextForXPathQuery(query)
    }
    
//    func clearHtmlTags() -> String? {
//        return self.replacePattern("<.*?>", withString: "")
//    }
//    
//    func clearNewLines() -> String {
//        return (self as NSString).stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "").stringByReplacingOccurrencesOfString("&#13;", withString: "")
//    }
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
    
    func containsSubString(substring: String) -> Bool {
        if self.rangeOfString(substring).location == NSNotFound {
            return false
        } else {
            return true
        }
    }
    
    func plainTextForXPathQuery(query: String) -> String {
        let elements = self.searchWithXPathQuery(query)
        if elements.count == 0 {
            return ""
        } else {
            let element = elements[0] as TFHppleElement
            return element.raw.stringByConvertingHTMLToPlainText().trimmed()
        }
    }
}

var associatedObjectKey: UInt8 = 0
extension TFHppleElement {
    /// Get realChildren, this will exclude nil child
    var realChildren: [TFHppleElement] {
        get {
            var realChildren: [TFHppleElement]?
            realChildren = objc_getAssociatedObject(self, &associatedObjectKey) as AnyObject? as? [TFHppleElement]
            if realChildren != nil {
                return realChildren!
            } else {
                realChildren = [TFHppleElement]()
                for child in self.children {
                    if let realChild: TFHppleElement = child as? TFHppleElement {
                        if realChild.raw != nil {
                            realChildren!.append(realChild)
                        }
                    }
                }
                objc_setAssociatedObject(self, &associatedObjectKey, realChildren, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return realChildren!
            }
        }
    }
    
    /**
    Return displayed string for a single node, no children is contained
    E.g., 
    1:
    <a name="sd" href="asd" title="asd">*Phone Type</a>
    return: "*Phone Type"
    
    2:
    <select name="DERIVED_SS_PD_PHONE_TYPE$0" id="DERIVED_SS_PD_PHONE_TYPE$0" tabindex="52" size="1" class="PSDROPDOWNLIST" style="width:221px; " onchange="addchg_win0(this);submitAction_win0(this.form,this.name);/*8000,200000*/">
        <option value="BUSN" selected="selected">Business</option>
        <option value="CELL">Cellular</option>
        <option value="HOME">Home</option>
        <option value="MAIL">Mailing</option>
    </select>
    return: "Business"
    
    3:
    <input type="text" name="SCC_PERS_PHN_H_PHONE$0" id="SCC_PERS_PHN_H_PHONE$0" tabindex="53" value="519/781-2862" class="PSEDITBOX" style="width:163px; " maxlength="24" onchange="addchg_win0(this);oChange_win0=this;/*108800,0*/">
    return: "519/781-2862"
    
    4:
    <span id="DELETE$span$0" class="SSSBUTTON_ACTIONLINK" title="Delete Entry">
        <a name="DELETE$0" id="DELETE$0" ptlinktgt="pt_peoplecode" tabindex="57" href="javascript:submitAction_win0(document.win0,'DELETE$0');" class="SSSBUTTON_ACTIONLINK">Delete</a>
    </span>
    return: "Delete"
    
    If this is a <div> and only contains one single node, will return the content for this single node, otherwise, return the first node's content
    
    :returns: The displayable content for this node
    */
    func displayableString() -> String? {
        if self.realChildren.count > 0 {
            // If self is select tag, continue
            if self.tagName != "select" {
                return realChildren[0].displayableString()
            }
        }
        if self.tagName == "select" {
            for childNode in self.realChildren {
                if childNode.tagName == "option" && childNode.hasKey("selected") && childNode.objectForKey("selected") == "selected" {
                    return (childNode.raw as String).stringByConvertingHTMLToPlainText().trimmed()
                }
            }
            return ""
        } else if self.tagName == "input" {
            return self.objectForKey("value")
        } else {
            return (self.raw as NSString).stringByConvertingHTMLToPlainText().trimmed()
        }
    }
    
    /**
    Return the first table 2d array in this element
    
    :returns: 2d array of the first table
    */
    func table2DArray() -> [[String]]? {
        if self.tagName != "table" {
            if !self.hasChildren() {
                return nil
            } else {
                return (self.firstChild as TFHppleElement).table2DArray()
             }
        } else  {
            var table = [[String]]()
            for rowElement in self.childrenWithTagName("tr") {
                var row = [String]()
                for colElement in rowElement.childrenWithTagName("th") {
                    row.append(colElement.displayableString() ?? "")
                }
                for colElement in rowElement.childrenWithTagName("td") {
                    row.append(colElement.displayableString() ?? "")
                }
                table.append(row)
            }
            return table
        }
    }
    
    func hasKey(key: String) -> Bool {
        return self.attributes.has(key)
    }
    
    func searchWithXPathQuery(queryString: String) -> [TFHppleElement] {
        return self.raw.searchWithXPathQuery(queryString)
    }
}

extension NSHTTPCookieStorage {
    class func cookieForKey(key: String, urlString: String) -> NSHTTPCookie? {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookiesForURL(NSURL(string: urlString)!) as [NSHTTPCookie]?
        if cookies != nil {
            for cookie: NSHTTPCookie in cookies! {
                if cookie.name == key {
                    return cookie
                }
            }
        }
        return nil
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
var appDelegate: AppDelegate { return UIApplication.sharedApplication().delegate! as AppDelegate}

// Debug Helpers

func addShadow(view: UIView) {
    let shadowPath = UIBezierPath(rect: view.bounds)
    view.layer.masksToBounds = false
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
    view.layer.shadowOpacity = 1.0
    view.layer.shadowPath = shadowPath.CGPath
}
