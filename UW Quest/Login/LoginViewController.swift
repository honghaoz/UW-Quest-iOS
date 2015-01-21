//
//  LoginViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/12/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

// TODO: Change loginButton appearance,
// TODO: Add cross indicator for textFields

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let kSwitchScaleFactor: CGFloat = 0.65
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: BaseButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var rememberLabel: UILabel!
    
    @IBOutlet weak var constraintRememberContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintRememberContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintRememberSwitchLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintRememberSwitchTop: NSLayoutConstraint!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var copyRightLabel: UILabel!
    
    var activeView: UIView! // Active view is active textField
    var keyboardRect: CGRect! = CGRectZero // Current keyboard rect
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.textColor = UQMainColor
        subTitleLabel.textColor = UQMainColor
        
        userIdTextField.backgroundColor = UIColor.whiteColor()
        userIdTextField.borderStyle = UITextBorderStyle.None
        userIdTextField.textColor = UQTextFieldFontColor
        userIdTextField.tintColor = UQMainColor
        
        separatorLineView.backgroundColor = kBorderColor
        
        passwordTextField.backgroundColor = UIColor.whiteColor()
        passwordTextField.borderStyle = UITextBorderStyle.None
        passwordTextField.textColor = UQTextFieldFontColor
        passwordTextField.tintColor = UQMainColor
        
        loginView.layer.borderColor = kBorderColor.CGColor
        loginView.layer.cornerRadius = kBorderCornerRadius
        loginView.layer.borderWidth = kBorderWidth
        
        loginButton.backgroundColor = UQMainColor
        loginButton.layer.borderColor = UQMainColor.CGColor
        loginButton.layer.cornerRadius = kBorderCornerRadius
        loginButton.layer.borderWidth = kBorderWidth
        loginButton.layer.masksToBounds = true
        
        rememberSwitch.on = true
        rememberSwitch.clipsToBounds = true
        rememberSwitch.onTintColor = UQMainColor
        
        // Scale switch
        rememberSwitch.transform = CGAffineTransformMakeScale(kSwitchScaleFactor, kSwitchScaleFactor)
        
        if (isIOS8) {
            let switchWidth: CGFloat = rememberSwitch.bounds.size.width
            let switchHeight: CGFloat = rememberSwitch.bounds.size.height
            let offsetX = (1.0 - kSwitchScaleFactor) * switchWidth / 2.0
            let offsetY = (1.0 - kSwitchScaleFactor) * switchHeight / 2.0
            let shrinkWidth = (1.0 - kSwitchScaleFactor) * switchWidth
            let shrinkHeight = (1.0 - kSwitchScaleFactor) * switchHeight
            constraintRememberSwitchLeading.constant = offsetX
            constraintRememberSwitchTop.constant = offsetY
            constraintRememberContainerWidth.constant = -shrinkWidth
            constraintRememberContainerHeight.constant = -shrinkHeight
        }
        
        rememberLabel.textColor = UQFontGrayColor
        forgotPasswordButton.setTitleColor(UQFontGrayColor, forState: UIControlState.Normal)
        forgotPasswordButton.tintColor = UQFontGrayColor
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)

        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
        // Model
        if Locator.user.load() {
            userIdTextField.text = Locator.user.username
            passwordTextField.text = Locator.user.password
        } else {
            Locator.user.isRemembered = rememberSwitch.on
        }
        
        // TextField target
        let textChangedAction: Selector = "textFieldDidChanged:"
        userIdTextField.addTarget(self, action: textChangedAction, forControlEvents: UIControlEvents.EditingChanged)
        passwordTextField.addTarget(self, action: textChangedAction, forControlEvents: UIControlEvents.EditingChanged)
        
        // Gestures for view
        let tapAction: Selector = "viewTapped:"
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:tapAction)
        tapGesture.numberOfTouchesRequired = 1
        self.contentView.addGestureRecognizer(tapGesture)
        
        let panAction: Selector = "viewPanned:"
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: panAction)
        self.contentView.addGestureRecognizer(panGesture)
        
        forgotPasswordButton.addTarget(self, action: "forgotPasswordButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let rememberSwitchAction: Selector = "rememberSwitchChanged:"
        rememberSwitch.addTarget(self, action: rememberSwitchAction, forControlEvents: UIControlEvents.ValueChanged)
        let rememberTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"rememberLabelTapped:" as Selector)
        rememberTapGesture.numberOfTouchesRequired = 1
        rememberLabel.addGestureRecognizer(rememberTapGesture)
        rememberLabel.userInteractionEnabled = true
        
        // Gesture for copyLable
        let copyRightTapAction: Selector = "copyRightLabelTapped:"
        var copyRightTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:copyRightTapAction)
        copyRightTapGesture.numberOfTouchesRequired = 1
        copyRightLabel.addGestureRecognizer(copyRightTapGesture)
        copyRightLabel.userInteractionEnabled = true
        
        self.updateViews()
        self.registerNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Notifications
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillChange:",
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        // Disable scrollable
        self.keyboardRect = CGRectZero
        self.scrollView.contentInset = UIEdgeInsetsZero
    }
    
    func keyboardWillChange(notification: NSNotification) {
        // Get keyboard end frame
        self.keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject? as? NSValue)?.CGRectValue()
        self.makeActiveViewVisible(self.keyboardRect)
    }
    
    // MARK: - Views update
    
    /**
    Make sure active textField is visible
    Note: scrollView's contentInset will be changed
    
    :param: keyboardRect Current keyboard frame
    */
    func makeActiveViewVisible(keyboardRect: CGRect) {
        var keyboardHeight: CGFloat = keyboardRect.size.height
        if (isIOS7 && (self.interfaceOrientation == UIInterfaceOrientation.LandscapeLeft || self.interfaceOrientation == UIInterfaceOrientation.LandscapeRight)) {
            keyboardHeight = keyboardRect.size.width
        }
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
        
        // Reduce mainFrame's height by keyboard height
        var mainFrame: CGRect = self.view.frame
        if isIOS7 {
            mainFrame = CGRectMake(self.view.frame.origin.y, self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width)
        }
        mainFrame.size.height -= keyboardHeight
        
        // Convert active view's origin into main view
        var convertedOrigin = self.activeView.convertPoint(self.activeView.bounds.origin, toView: self.view)
        // Add view's height and give 40 points (One extra textField) bottom spacing
        convertedOrigin.y += self.activeView.bounds.size.height + 40.0
        
        // If keyboard is covering this view, scroll to visible area
        if (!CGRectContainsPoint(mainFrame, convertedOrigin)) {
            // Convert activeView's frame to scrollView
            var targetFrame = self.activeView.convertRect(self.activeView.bounds, toView: self.scrollView)
            // Add bottom spacing
            var moveDownOffset: CGFloat = self.activeView.bounds.size.height + 30.0//50.0
            targetFrame.origin.y += moveDownOffset
            
            self.scrollView.scrollRectToVisible(targetFrame, animated: true)
        }
    }
    
    func updateViews() {
        if (userIdTextField.text.isEmpty || passwordTextField.text.isEmpty) {
            loginButton.enabled = false
        } else {
            loginButton.enabled = true
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let newTag = textField.tag + 1
        var nextTextField: UITextField? = textField.superview?.viewWithTag(newTag) as UITextField?
        if let realTextField = nextTextField {
            nextTextField?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.loginButtonPressed(textField)
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeView = textField;
        if !CGRectEqualToRect(self.keyboardRect, CGRectZero) {
            self.makeActiveViewVisible(self.keyboardRect)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeView = nil;
    }
    
    func textFieldDidChanged(sender: AnyObject) {
        self.updateViews()
    }
    
    // MARK: Actions
    @IBAction func loginButtonPressed(sender: AnyObject) {
        dismissKeyboard()
        self.showHud("Login...   ")
        Locator.user.username = userIdTextField.text
        Locator.user.password = passwordTextField.text
        Locator.user.login({ () -> () in
            logInfo("Login Successfully")
            if self.rememberSwitch.on {
                Locator.user.save()
            }
            JGProgressHUD.showSuccess("Success!", duration: 1.0)
            self.enterToMainScreen()
        }, failure: { (errorMessage, error) -> () in
            logInfo("Login Failed")
            JGProgressHUD.showFailure(errorMessage,  duration: 1.5)
        })
    }
    
    func viewTapped(recognizer: UIGestureRecognizer) {
        self.dismissKeyboard()
    }
    
    func viewPanned(recognizer: UIGestureRecognizer) {
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
        userIdTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func rememberLabelTapped(recognizer: UIGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            rememberSwitch.setOn(!rememberSwitch.on, animated: true)
            self.rememberSwitchChanged(nil)
        }
    }
    
    func rememberSwitchChanged(sender: AnyObject?) {
        logVerbose("Remember: \(rememberSwitch.on)")
        User.sharedUser.isRemembered = rememberSwitch.on
    }
    
    func forgotPasswordButtonTapped(recognizer: UIGestureRecognizer) {
        var alert = UIAlertController(title: "Go to WATIAM website", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {alertAction in
            ARAnalytics.event("Cancel go to WATIAM website")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Cancel, handler: { alertAction in
            logInfo("Go to WATIAM website")
            ARAnalytics.event("Go to WATIAM website")
            UIApplication.sharedApplication().openURL(NSURL(string: watiamURLString)!)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func copyRightLabelTapped(recognizer: UIGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            var alert = UIAlertController(title: "Open Honghao's website", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {alertAction in
                ARAnalytics.event("Cancel go to HonghaoZ website")
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Cancel, handler: { alertAction in
                logInfo("Go to HonghaoZ website")
                ARAnalytics.event("Go to HonghaoZ website")
                UIApplication.sharedApplication().openURL(NSURL(string: honghaoLinkedInURLString)!)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Helper
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func enterToMainScreen() {
        // Enter
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            appDelegate.window?.rootViewController = Locator.slidingViewController
            UIView.transitionWithView(appDelegate.window!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                appDelegate.window!.rootViewController = Locator.slidingViewController
                }, completion: nil)
        })
    }

}
