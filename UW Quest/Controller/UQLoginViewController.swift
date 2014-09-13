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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.textColor = kButtonColor
        subTitleLabel.textColor = kButtonColor
        
        userIdTextField.backgroundColor = UIColor.clearColor()
        userIdTextField.borderStyle = UITextBorderStyle.None
        
        separatorLineView.backgroundColor = kBorderColor
        
        passwordTextField.backgroundColor = UIColor.clearColor()
        passwordTextField.borderStyle = UITextBorderStyle.None
        
        loginView.layer.borderColor = kBorderColor.CGColor
        loginView.layer.cornerRadius = kBorderCornerRadius
        loginView.layer.borderWidth = kBorderWidth
        
        loginButton.backgroundColor = kButtonColor
        loginButton.layer.borderColor = kButtonColor.CGColor
        loginButton.layer.cornerRadius = kBorderCornerRadius
        loginButton.layer.borderWidth = kBorderWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapAction: Selector = "viewTapped:"
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:tapAction)
        tapGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userIdTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //TODO: complete next responder
        return true
    }
    
    // MARK: Actions
    
    func viewTapped(sender: AnyObject) {
        userIdTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
