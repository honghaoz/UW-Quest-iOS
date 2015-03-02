//
//  MyClassScheduleTermViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class MyClassScheduleTermViewController: UIViewController {

    @IBOutlet weak var headerTermLabel: UILabel!
    @IBOutlet weak var headerLevelLabel: UILabel!
    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var headerInformationLabel: ZHAutoLinesLabel!
    
    @IBOutlet weak var collectionView: ZHDynamicCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spring 2014"
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        self.view.backgroundColor = UQBackgroundColor
    }
}

// MARK: CollectionView
extension MyClassScheduleTermViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var kSectionHorizontalInsets: CGFloat { return 10.0 }
    var kSectionVerticalInsets: CGFloat { return 10.0 }
    
    var kCourseHeaderCell: String { return "CourseHeaderCell" }
    var kCourseComponentCell: String { return "CourseComponentCell" }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Registeration
        collectionView.registerNib(UINib(nibName: "CourseHeaderCell", bundle: nil), forCellWithReuseIdentifier: kCourseHeaderCell)
        collectionView.registerClass(CourseComponentCell.self, forCellWithReuseIdentifier: kCourseComponentCell)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseHeaderCell, forIndexPath: indexPath) as! CourseHeaderCell
                // Cell configuration
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseComponentCell, forIndexPath: indexPath) as! CourseComponentCell
                // Cell configuration
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseComponentCell, forIndexPath: indexPath) as! CourseComponentCell
                // Cell configuration
                return cell
            default:
                assertionFailure("wrong indexPath.item")
            }
        default:
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseHeaderCell, forIndexPath: indexPath) as! CourseHeaderCell
                // Cell configuration
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseComponentCell, forIndexPath: indexPath) as! CourseComponentCell
                // Cell configuration
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseComponentCell, forIndexPath: indexPath) as! CourseComponentCell
                // Cell configuration
                return cell
            default:
                assertionFailure("wrong indexPath.item")
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            let targetWidth: CGFloat = collectionView.bounds.width - 2 * kSectionHorizontalInsets
            let cell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kCourseHeaderCell) as! CourseHeaderCell
            cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
            cell.contentView.bounds = cell.bounds
            var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            if abs(size.width - targetWidth) > 1 {
                size.width = targetWidth
            }
            return size
        default:
            let targetWidth: CGFloat = collectionView.bounds.width - 2 * kSectionHorizontalInsets
            let cell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kCourseComponentCell) as! CourseComponentCell
            cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
            cell.contentView.bounds = cell.bounds
            var size = cell.contentView.systemLayoutSizeFittingSize(CGSizeMake(targetWidth, cell.bounds.height))
            if abs(size.width - targetWidth) > 1 {
                size.width = targetWidth
            }
            return size
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(kSectionVerticalInsets, kSectionHorizontalInsets, kSectionVerticalInsets, kSectionHorizontalInsets)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}
