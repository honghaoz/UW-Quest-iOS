//
//  PersonalInfoViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
        return 1//numberOfCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        logMethod()
        var cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
//        cell.setNeedsUpdateConstraints()
//        cell.updateConstraintsIfNeeded()
        println("end cell for")
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
        let reuseIdentifier = kAddressCellReuseIdentifier
//////        var cell: AddressCollectionViewCell?
        var cell: AddressCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? AddressCollectionViewCell
        if cell == nil {
            println("dequeue")
            cell = NSBundle.mainBundle().loadNibNamed("AddressCollectionViewCell", owner: self, options: nil)[0] as? AddressCollectionViewCell
            self.offscreenCells[reuseIdentifier] = cell
        }

        println("init cell!!!!!")
//
        println("bounds: \(cell!.bounds)")
        println("contentView.bounds: \(cell!.contentView.bounds)")
//
//        cell!.setNeedsUpdateConstraints()
//        cell!.updateConstraintsIfNeeded()
//
//        
//        println("bounds: \(cell!.bounds)")
//        println("contentView.bounds: \(cell!.contentView.bounds)")
//
//////        cell!.bounds = CGRectMake(0, 0, collectionView.contentSize.width - 20, CGRectGetHeight(cell!.bounds))
//////        
        cell!.setNeedsLayout()
        cell!.layoutIfNeeded()
        
        println("bounds: \(cell!.bounds)")
        println("contentView.bounds: \(cell!.contentView.bounds)")
//
//        
//        
        var size = cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        println("old size: \(size)")
        size.width = collectionView.bounds.width - 20
        println("new size: \(size)")
        return size
//        println("size: \(CGSizeMake(collectionView.bounds.width - 20, 120))")
//        return CGSizeMake(collectionView.bounds.width - 20, 120)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        logMethod()
        return UIEdgeInsetsMake(10, 10, 10, 10)
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
