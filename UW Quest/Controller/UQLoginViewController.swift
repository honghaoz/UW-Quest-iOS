//
//  UQLoginViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/12/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class UQLoginViewController: UIViewController, UITextFieldDelegate {
    
    let kBorderColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    let kBorderCornerRadius: CGFloat = 5.0
    let kBorderWidth: CGFloat = 1.0
    
    let kButtonColor: UIColor = UIColor(red: 0.22, green: 0.48, blue: 0.69, alpha: 1)
    let kRememberTitleColor: UIColor = UIColor(white: 0.4, alpha: 1)
    
    let watiamURLString = "https://watiam.uwaterloo.ca/idm/user/login.jsp"
    let honghaozURLString = "http://honghaoz.com"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var switchToLoginButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var rememberLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var copyRightLabel: UILabel!
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.textColor = kButtonColor
        subTitleLabel.textColor = kButtonColor
        
        userIdTextField.backgroundColor = UIColor.whiteColor()
        userIdTextField.borderStyle = UITextBorderStyle.None
        
        separatorLineView.backgroundColor = kBorderColor
        
        passwordTextField.backgroundColor = UIColor.whiteColor()
        passwordTextField.borderStyle = UITextBorderStyle.None
        
        loginView.layer.borderColor = kBorderColor.CGColor
        loginView.layer.cornerRadius = kBorderCornerRadius
        loginView.layer.borderWidth = kBorderWidth
        
        loginButton.backgroundColor = kButtonColor
        loginButton.layer.borderColor = kButtonColor.CGColor
        loginButton.layer.cornerRadius = kBorderCornerRadius
        loginButton.layer.borderWidth = kBorderWidth
        
        let switchScaleFactor: CGFloat = 0.65
        let switchWidth: CGFloat = rememberSwitch.bounds.size.width
        let switchHeight: CGFloat = rememberSwitch.bounds.size.height
        let offsetX = (1.0 - switchScaleFactor) * switchWidth / 2.0
        let makeItSmaller: CGAffineTransform = CGAffineTransformMakeScale(switchScaleFactor, switchScaleFactor)
        rememberSwitch.transform = CGAffineTransformMakeScale(switchScaleFactor, switchScaleFactor)
        switchToLoginButtonLeading.constant = -offsetX
        rememberSwitch.onTintColor = kButtonColor
        
        rememberLabel.textColor = kRememberTitleColor
        forgotPasswordButton.tintColor = kRememberTitleColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapAction: Selector = "viewTapped:"
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:tapAction)
        tapGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        let panAction: Selector = "viewPanned:"
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: panAction)
        self.view.addGestureRecognizer(panGesture)
        
        forgotPasswordButton.addTarget(self, action: "forgotPasswordButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
