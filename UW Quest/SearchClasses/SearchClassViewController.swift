//
//  SearchClassViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/20/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class SearchClassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupAnimation()
    }
    
    private func setupAnimation() {
        // Default animation
        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
        //        // Dynamic transition
        //        var dynamicTransition = Locator.sharedLocator.dynamicTransition
        //        dynamicTransition.slidingViewController = self.slidingViewController()
        //        self.slidingViewController().delegate = dynamicTransition
        //
        //        self.slidingViewController().topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesture.Tapping | ECSlidingViewControllerAnchoredGesture.Custom
        //
        //        var dynamicTransitionPanGesture = UIPanGestureRecognizer(target: dynamicTransition, action: "handlePanGesture:")
        //        self.slidingViewController().customAnchoredGestures = [dynamicTransitionPanGesture]
        //        self.navigationController?.view.addGestureRecognizer(dynamicTransitionPanGesture)
        //
        //        // Zoom transition
        //        let zoomTransition = Locator.sharedLocator.zoomTransition
        //        self.slidingViewController().delegate = zoomTransition
        //        self.slidingViewController().topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesture.Tapping | ECSlidingViewControllerAnchoredGesture.Panning
        //
        //        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
}
