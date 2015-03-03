//
//  MyClassScheduleTermViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class MyClassScheduleTermViewController: BaseRootViewController {

    @IBOutlet weak var headerTermLabel: UILabel!
    @IBOutlet weak var headerLevelLabel: UILabel!
    @IBOutlet weak var headerLocationLabel: UILabel!
//    @IBOutlet weak var headerInformationLabel: ZHAutoLinesLabel!
    
    @IBOutlet weak var collectionView: ZHDynamicCollectionView!
    var cellCollectionViewContentOffset = [NSIndexPath: CGPoint]()
    
    weak var classSchedule: ClassSchedule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        self.view.backgroundColor = UQBackgroundColor
    }
    
    func update() {
        precondition(Locator.user.classSchedule != nil, "User's classSchedule must be not nil")
        classSchedule = Locator.user.classSchedule
        self.title = classSchedule.term
        self.headerTermLabel.text = classSchedule.term
        self.headerLevelLabel.text = classSchedule.academicLevel
        self.headerLocationLabel.text = classSchedule.location
        
        self.collectionView.reloadData()
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
        if classSchedule == nil {
            return 0
        } else {
            return classSchedule.courses.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseHeaderCell, forIndexPath: indexPath) as! CourseHeaderCell
            // Cell configuration
            configCourseHeaderCell(cell, sectionNumber: indexPath.section)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCourseComponentCell, forIndexPath: indexPath) as! CourseComponentCell
            // Cell configuration
            logDebug("cell: \(cell), indexPath: \(indexPath)")
            configCourseComponentCell(cell, indexPath: indexPath, requireReloadData: true)
            return cell
        default:
            assertionFailure("wrong indexPath.item")
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            let targetWidth: CGFloat = collectionView.bounds.width - 2 * kSectionHorizontalInsets
            let cell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kCourseHeaderCell) as! CourseHeaderCell
            configCourseHeaderCell(cell, sectionNumber: indexPath.section)
            
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
            configCourseComponentCell(cell, indexPath: indexPath, requireReloadData: false)
            
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
    
    // MARK: 
    
    func configCourseHeaderCell(cell: CourseHeaderCell, sectionNumber: Int) {
        let course = classSchedule.courses[sectionNumber]
        cell.courseNumberLabel.text = course.courseNumber
        cell.enrollStateLabel.text = course.enrollStatus
        cell.courseNameLabel.text = course.courseTitle
        cell.unitValueLabel.text = course.units
        cell.gradeValueLabel.text = course.grade.isEmpty ? "-" : course.grade
        cell.gradingValueLabel.text = course.grading
    }
    
    func configCourseComponentCell(cell: CourseComponentCell, indexPath: NSIndexPath, requireReloadData: Bool) {
        cell.delegate = self
        if requireReloadData {
            // Must call reload data to avoid crash
            cell.scheduleCollectionView.collectionViewLayout.invalidateLayout()
            cell.scheduleCollectionView.reloadData()
            (cell.scheduleCollectionView as UIScrollView).delegate = self
        }
        
        // Record schedule collectionView contentOffset
        if cellCollectionViewContentOffset.has(indexPath) {
            cell.scheduleCollectionView.setContentOffset(cellCollectionViewContentOffset[indexPath]!, animated: false)
        } else {
            cell.scheduleCollectionView.setContentOffset(CGPointZero, animated: false)
            cellCollectionViewContentOffset[indexPath] = cell.scheduleCollectionView.contentOffset
        }

        // Calculate collectionHeight
        var height: CGFloat = 0
        var numberOfRows = classSchedule.courses[indexPath.section].courseScheduleComponentTable.count - 1
        height += cell.tableLayout.titleLabelHeight + cell.tableLayout.verticalPadding * 2
        height += cell.tableLayout.separatorLineWidth
        height += (cell.tableLayout.contentLabelHeight + 2 * cell.tableLayout.verticalPadding) * CGFloat(numberOfRows)
        height += 8 // Add extra space for indicator
        cell.cCollectionViewHeight.constant = height
    }
}

extension MyClassScheduleTermViewController: CourseComponentCellDelegate {
    func numberOfColumnsInCell(cell: CourseComponentCell) -> Int {
        if let indexPath = self.collectionView.indexPathForCell(cell) {
            return classSchedule.courses[indexPath.section].courseScheduleComponentTable[0].count
        } else {
            return 0
        }
    }
    
    func numberOfRowsInColumn(column: Int, cell: CourseComponentCell) -> Int {
        let indexPath = self.collectionView.indexPathForCell(cell)
        return classSchedule.courses[indexPath!.section].courseScheduleComponentTable.count - 1
    }
    
    func titleForColumn(column: Int, cell: CourseComponentCell) -> String {
        let indexPath = self.collectionView.indexPathForCell(cell)
        return classSchedule.courses[indexPath!.section].courseScheduleComponentTable[0][column]
    }
    
    func contentForColumn(column: Int, row: Int, cell: CourseComponentCell) -> String {
        let indexPath = self.collectionView.indexPathForCell(cell)
        return classSchedule.courses[indexPath!.section].courseScheduleComponentTable[row + 1][column]
    }
}

extension MyClassScheduleTermViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Record last contentOffset for schedule collectionView
        if scrollView.isKindOfClass(TableCollectionView) {
            if let cell = scrollView.retrieveObject() as? CourseComponentCell {
                if let indexPath = self.collectionView.indexPathForCell(cell) {
                   cellCollectionViewContentOffset[indexPath] = scrollView.contentOffset
                }
            }
        }
    }
}
