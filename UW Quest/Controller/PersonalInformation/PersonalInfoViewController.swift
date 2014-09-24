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
    
    var numberOfCells = 0

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Personal Information"
        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
        collectionView.dataSource = self
        collectionView.delegate = self
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
//        return self.titlesArray.count
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
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
        return CGSizeMake(50, 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    // MARK: - Header tap gesture action
    func headerViewTapped(tapGesture: UITapGestureRecognizer) {
        var headerView = tapGesture.view as UQCollectionReusableView
        println("tapped header: \(headerView.indexPath)")
        let tappedSection = headerView.indexPath.section
        
        self.numberOfCells = self.numberOfCells == 0 ? 1: 0
        
        self.collectionView.reloadSections(NSIndexSet(index: tappedSection))
        
        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.Addresses, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.PhoneNumbers, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.EmailAddresses, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.EmergencyContacts, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.DemographicInformation, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInfomation.CitizenshipImmigrationDocuments, success: nil, failure: nil)
    }
    
    // MARK: - Helper
    func attachTapGestureForHeaderView(headerView: UICollectionReusableView) {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "headerViewTapped:" as Selector)
        tapGesture.numberOfTouchesRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
}
