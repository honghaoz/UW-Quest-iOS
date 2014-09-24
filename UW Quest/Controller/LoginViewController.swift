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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.backgroundColor = UQBackgroundColor
        
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
        Locator.sharedLocator.user.isRemembered = rememberSwitch.on
        
        // TextField target
        let textChangedAction: Selector = "textFieldDidChanged:"
        userIdTextField.addTarget(self, action: textChangedAction, forControlEvents: UIControlEvents.EditingChanged)
        passwordTextField.addTarget(self, action: textChangedAction, forControlEvents: UIControlEvents.EditingChanged)
        
        // Gestures for view
        let tapAction: Selector = "viewTapped:"
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:tapAction)
        tapGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        let panAction: Selector = "viewPanned:"
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: panAction)
        self.view.addGestureRecognizer(panGesture)
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func textFieldDidChanged(sender: AnyObject) {
        self.updateViews()
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        dismissKeyboard()
        self.showHud("Login...   ")
        Locator.sharedLocator.user.username = userIdTextField.text
        Locator.sharedLocator.user.password = passwordTextField.text
        Locator.sharedLocator.user.login({ () -> () in
            println("Login Successfully")
            JGProgressHUD.showSuccess("Success!", duration: 1.0)
            self.enterToMainScreen()
        }, failure: { (errorMessage, error) -> () in
            println("Login Failed")
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
        println("Remember: \(rememberSwitch.on)")
        User.sharedUser.isRemembered = rememberSwitch.on
    }
    
    func forgotPasswordButtonTapped(recognizer: UIGestureRecognizer) {
        var alert = UIAlertController(title: "Go to WATIAM website", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {alertAction in
            ARAnalytics.event("Cancel go to WATIAM website")
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Cancel, handler: { alertAction in
            println("Go to WATIAM website")
            ARAnalytics.event("Go to WATIAM website")
            UIApplication.sharedApplication().openURL(NSURL(string: watiamURLString))
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
                println("Go to HonghaoZ website")
                ARAnalytics.event("Go to HonghaoZ website")
                UIApplication.sharedApplication().openURL(NSURL(string: honghaoLinkedInURLString))
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Helper
    
    func enterToMainScreen() {
        // Enter
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            Locator.sharedLocator.appDelegate.window?.rootViewController = Locator.sharedLocator.slidingViewController
            UIView.transitionWithView(Locator.sharedLocator.appDelegate.window!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                Locator.sharedLocator.appDelegate.window?.rootViewController = Locator.sharedLocator.slidingViewController
                return
                }, completion: nil)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
