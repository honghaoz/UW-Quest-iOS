//
//  PersonalInfoViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let kSectionHorizontalInsets: CGFloat = 10.0
    let kSectionVerticalInsets: CGFloat = 10.0
    
//    let kAddressesTitle = "Addresses"
//    let kNamesTitle = "Names"
//    let kPhoneNumbersTitle = "Phone Numbers"
//    let kEmailAddressesTitle = "Email Addresses"
//    let kEmergencyContactsTitle = "Emergency Contacts"
//    let kDemographicInformationTitle = "Demographic Information"
//    let kCitizenshipImmigrationDocumentsTitle = "Citizenship/Immigration Documents"
//    
    let kHeaderViewReuseIdentifier = "HeaderView"
    let kAddressCellReuseIdentifier = "AddressCell"
//    let kNameCellResueIdentifier = "NameCell"
//    let kPhoneNumberCellResueIdentifier = "PhoneNumberCell"
//    let kEmailAddressCellResueIdentifier = "EmailAddressCell"
//    let kEmergencyContactCellResueIdentifier = "EmergencyContactCell"
//    let kDemograhicCellResueIdentifier = "DemographicCell"
//    let kCitizenshipCellResueIdentifier = "CitizenshipCell"
//    
//    var titlesArray: [String] = [kAddressesTitle, kNamesTitle, kPhoneNumbersTitle, kEmailAddressesTitle, kEmergencyContactsTitle, kDemographicInformationTitle, kCitizenshipImmigrationDocumentsTitle]
    
    // A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
    // handle the height calculations. These are never drawn onscreen. The dictionary is in the format:
    //      { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
    var offscreenCells = Dictionary<String, UICollectionViewCell>();
    
    var numberOfCells = 0

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Personal Information"
        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cells
        var addressCellNib = UINib(nibName: "AddressCollectionViewCell", bundle: nil)
        collectionView.registerNib(addressCellNib, forCellWithReuseIdentifier: kAddressCellReuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        logMethod()
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        logMethod()
        return numberOfCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        logMethod()
        var cell: AddressCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as AddressCollectionViewCell
        // There's no need to update constraints
//        cell.setNeedsUpdateConstraints()
//        cell.updateConstraintsIfNeeded()
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        println("    typeLabel: \(cell.typeLabel.frame)")
        println("    addressLabel: \(cell.addressLabel.frame)")
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        logMethod()
        var headerView: UQCollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kHeaderViewReuseIdentifier, forIndexPath: indexPath) as UQCollectionReusableView
        
        // First section header, hide topSeparator line
        if (indexPath.section == 0) {
            headerView.topSeparator.hidden = true
            headerView.bottomSeparator.hidden = true
        } else {
            headerView.topSeparator.hidden = false
            headerView.bottomSeparator.hidden = true
        }
        
        headerView.indexPath = indexPath
        self.attachTapGestureForHeaderView(headerView)
        
        return headerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        logMethod()
        // Set up desired width
        let targetWidth = collectionView.bounds.width - 2 * kSectionHorizontalInsets
        
        // Use fake cell to calculate height
        let reuseIdentifier = kAddressCellReuseIdentifier
        var cell: AddressCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? AddressCollectionViewCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("AddressCollectionViewCell", owner: self, options: nil)[0] as? AddressCollectionViewCell
            self.offscreenCells[reuseIdentifier] = cell
        }
        
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
        cell!.bounds = CGRectMake(0, 0, targetWidth, cell!.bounds.height)
        cell!.contentView.bounds = cell!.bounds
        
//        // Not sure whether need to update constraint, no need
//        cell!.setNeedsUpdateConstraints()
//        cell!.updateConstraintsIfNeeded()

        // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
        cell!.setNeedsLayout()
        cell!.layoutIfNeeded()
 
        var size = cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        // Still need to force the width, since width can be smalled due to break mode of labels
        size.width = targetWidth
        println("size: \(size)")
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        logMethod()
        return UIEdgeInsetsMake(kSectionVerticalInsets, kSectionHorizontalInsets, kSectionVerticalInsets, kSectionHorizontalInsets)
    }
    
    // MARK: - Header tap gesture action
    func headerViewTapped(tapGesture: UITapGestureRecognizer) {
        var headerView = tapGesture.view as UQCollectionReusableView
        println("tapped header: \(headerView.indexPath)")
        let tappedSection = headerView.indexPath.section
        
        self.numberOfCells = self.numberOfCells == 0 ? 1: 0
        
        self.collectionView.reloadSections(NSIndexSet(index: tappedSection))
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformationType.Addresses, success:{ _ in
//            println("\(Locator.sharedLocator.user.personalInformation.addresses!)")
//            }, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.PhoneNumbers, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.EmailAddresses, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.EmergencyContacts, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.DemographicInformation, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.CitizenshipImmigrationDocuments, success: nil, failure: nil)
    }
    
    // MARK: - Helper
    func attachTapGestureForHeaderView(headerView: UICollectionReusableView) {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "headerViewTapped:" as Selector)
        tapGesture.numberOfTouchesRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
}
