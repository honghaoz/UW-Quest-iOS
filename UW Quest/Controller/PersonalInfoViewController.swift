//
//  PersonalInfoViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Personal Information"
        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
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
