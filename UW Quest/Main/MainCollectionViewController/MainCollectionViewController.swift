//
//  MainCollectionViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

// TODO: Slide out status bar when showing menu VC
// TODO: Don't show loading HUD, load all information once
// TODO: Different iPad cell size

import UIKit

protocol MainCollectionVCImplementation {
    var title: String { get }
    var mainCollectionVC: MainCollectionViewController! { get set }
    var collectionView: ZHDynamicCollectionView! { get set }
    func setUp(collectionVC: MainCollectionViewController)
    // Data Source
    func numberOfSectionsInCollectionView() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    func cellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell
    func titleForHeaderAtIndexPath(indexPath: NSIndexPath) -> String
    // FlowLayout
    func sizeForItemAtIndexPath(indexPath: NSIndexPath, layout collectionViewLayout: UICollectionViewLayout) -> CGSize
    // Actions
    func headerViewTapped(headerView: UQCollectionReusableView)
}

class MainCollectionViewController: UIViewController {
    
    var currentImplemention: MainCollectionVCImplementation!
    var currentShowingSection: Int = -1
    
    @IBOutlet weak var collectionView: ZHDynamicCollectionView!
    
    init(implementation: MainCollectionVCImplementation) {
        super.init()
        self.setup(implementation)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(implementation: MainCollectionVCImplementation) {
        currentImplemention = implementation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        self.navigationController?.title = currentImplemention.title
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        setupAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        self.slidingViewController().anchorTopViewToRightAnimated(true)
    }
    
    // MARK: - Header tap gesture action
    func headerViewTapped(tapGesture: UITapGestureRecognizer) {
        var headerView = tapGesture.view as! UQCollectionReusableView
        currentShowingSection = currentShowingSection == headerView.indexPath.section ? -1 : headerView.indexPath.section
        currentImplemention.headerViewTapped(headerView)
    }
}

// MARK: CollectionView
extension MainCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var kSectionHorizontalInsets: CGFloat { return 10.0 }
    var kSectionVerticalInsets: CGFloat { return 10.0 }
    
    var kHeaderViewReuseIdentifier: String { return "HeaderView" }
    var kDescriptionCellResueIdentifier: String { return "DescriptionCell" }
    
    private func setupCollectionView() {
        currentImplemention = PersonalInfoImplementation()
        currentImplemention.setUp(self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Registeration
        collectionView.registerClass(DescriptionCollectionViewCell.self, forCellWithReuseIdentifier: kDescriptionCellResueIdentifier)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return currentImplemention.numberOfSectionsInCollectionView()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentImplemention.numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return currentImplemention.cellForItemAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var headerView: UQCollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kHeaderViewReuseIdentifier, forIndexPath: indexPath) as! UQCollectionReusableView
        
        // First section header, hide topSeparator line
        if (indexPath.section == 0) {
            headerView.topSeparator.hidden = true
            headerView.bottomSeparator.hidden = true
        } else  {
            headerView.topSeparator.hidden = false
            headerView.bottomSeparator.hidden = true
        }
        
        // For current showing section
        if (indexPath.section == currentShowingSection) {
            headerView.bottomSeparator.hidden = true
        }
        if (indexPath.section == currentShowingSection + 1) {
            headerView.topSeparator.hidden = true
        }
        
        headerView.indexPath = indexPath
        self.attachTapGestureForHeaderView(headerView)
        
        headerView.titleLabel.text = currentImplemention.titleForHeaderAtIndexPath(indexPath)
        
        return headerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return currentImplemention.sizeForItemAtIndexPath(indexPath, layout: collectionViewLayout)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == currentShowingSection {
            return UIEdgeInsetsMake(kSectionVerticalInsets, kSectionHorizontalInsets, kSectionVerticalInsets, kSectionHorizontalInsets)
        } else {
            return UIEdgeInsetsMake(0, kSectionHorizontalInsets, 0, kSectionHorizontalInsets)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kSectionHorizontalInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kSectionVerticalInsets
    }
}

// MARK: Rotation
extension MainCollectionViewController {
    // iOS7
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // iOS8
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Helper
    func attachTapGestureForHeaderView(headerView: UICollectionReusableView) {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "headerViewTapped:" as Selector)
        tapGesture.numberOfTouchesRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
}
