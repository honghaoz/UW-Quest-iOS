//
//  LoginViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/12/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: BaseButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var rememberLabel: UILabel!
    @IBOutlet weak var rememberSwitch_LoginButton_Leading: NSLayoutConstraint!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var copyRightLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("viewDidLayoutSubview");
        titleLabel.textColor = UQBlueColor
        subTitleLabel.textColor = UQBlueColor
        
        userIdTextField.backgroundColor = UIColor.whiteColor()
        userIdTextField.borderStyle = UITextBorderStyle.None
        
        separatorLineView.backgroundColor = kBorderColor
        
        passwordTextField.backgroundColor = UIColor.whiteColor()
        passwordTextField.borderStyle = UITextBorderStyle.None
        
        loginView.layer.borderColor = kBorderColor.CGColor
        loginView.layer.cornerRadius = kBorderCornerRadius
        loginView.layer.borderWidth = kBorderWidth
        
        loginButton.backgroundColor = UQBlueColor
        loginButton.layer.borderColor = UQBlueColor.CGColor
        loginButton.layer.cornerRadius = kBorderCornerRadius
        loginButton.layer.borderWidth = kBorderWidth
        loginButton.layer.masksToBounds = true
        
        rememberSwitch.onTintColor = UQBlueColor
        
        rememberLabel.textColor = UQFontGrayColor
        forgotPasswordButton.tintColor = UQFontGrayColor
        
        println("111button: \(loginButton.frame)")
        println("111old : \(rememberSwitch.frame)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let switchScaleFactor: CGFloat = 0.65
        let switchWidth: CGFloat = rememberSwitch.bounds.size.width
        let switchHeight: CGFloat = rememberSwitch.bounds.size.height
        let offsetX = (1.0 - switchScaleFactor) * switchWidth / 2.0
        
        println("old \(rememberSwitch_LoginButton_Leading.constant)")
        println("old anchor \(rememberSwitch.layer.anchorPoint)")
        
        rememberSwitch.clipsToBounds = true
        println("button: \(loginButton.frame)")
        println("old center: \(rememberSwitch.center)")
        println("old: \(rememberSwitch.frame)")
        rememberSwitch.transform = CGAffineTransformMakeScale(switchScaleFactor, switchScaleFactor)
//        rememberSwitch_LoginButton_Leading.constant = -offsetX
        println("new center: \(rememberSwitch.center)")
        println("new: \(rememberSwitch.frame)")
        println("new anchor \(rememberSwitch.layer.anchorPoint)")
        println("new \(rememberSwitch_LoginButton_Leading.constant)")
//        self.view.layoutSubviews()
//        self.view.layoutIfNeeded()
        self.view.updateConstraints()
        self.view.updateConstraintsIfNeeded()
        self.view.setNeedsUpdateConstraints()
        self.view.setNeedsLayout()
        
//        func updateConstraintsIfNeeded() // Updates the constraints from the bottom up for the view hierarchy rooted at the receiver. UIWindow's implementation creates a layout engine if necessary first.
//        @availability(iOS, introduced=6.0)
//        func updateConstraints() // Override this to adjust your special constraints during a constraints update pass
//        @availability(iOS, introduced=6.0)
//        func needsUpdateConstraints() -> Bool
//        @availability(iOS, introduced=6.0)
//        func setNeedsUpdateConstraints()
        
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let newTag = textField.tag + 1
        var nextTextField: UITextField? = textField.superview?.viewWithTag(newTag) as UITextField?
        if let realTextField = nextTextField {
            nextTextField?.becomeFirstResponder()
            //TODO: call login
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Actions
    
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
        println("Go to WATIAM website")
        // TODO: Ask user when leaving app
        UIApplication.sharedApplication().openURL(NSURL(string: watiamURLString))
    }
    
    func copyRightLabelTapped(recognizer: UIGestureRecognizer) {
        println("Go to HonghaoZ website")
        // TODO: Ask user when leaving app
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            UIApplication.sharedApplication().openURL(NSURL(string: honghaozURLString))
        }
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
