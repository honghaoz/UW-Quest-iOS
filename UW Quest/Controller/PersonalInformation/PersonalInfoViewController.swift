//
//  PersonalInfoViewController.swift
//  UW Quest
//
//  Created by Honghao on 9/21/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var sharedPersonalInformation: PersonalInformation!
    
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
        
        // Setup
        sharedPersonalInformation = Locator.sharedLocator.user.personalInformation
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
        return sharedPersonalInformation.categories.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let choosedCase: PersonalInformationType = PersonalInformationType.fromRaw(sharedPersonalInformation.categories[section])!
        switch choosedCase {
        case PersonalInformationType.Addresses:
            return sharedPersonalInformation.addresses!.count
        case PersonalInformationType.Names:
            return 0
        case PersonalInformationType.PhoneNumbers:
            return 0
        case PersonalInformationType.EmailAddresses:
            return 0
        case PersonalInformationType.EmergencyContacts:
            return 0
        case PersonalInformationType.DemographicInformation:
            return 0
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            return 0
        default:
            assert(false, "Wrong PersonalInformation Type")
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: AddressCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as AddressCollectionViewCell
        
        let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
        cell.configWithType(address.type, address: address.address)
        
        cell.layoutIfNeeded()
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
        // Set up desired width
        let targetWidth: CGFloat = collectionView.bounds.width - 2 * kSectionHorizontalInsets
        
        // Use fake cell to calculate height
        let reuseIdentifier = kAddressCellReuseIdentifier
        var cell: AddressCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? AddressCollectionViewCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("AddressCollectionViewCell", owner: self, options: nil)[0] as? AddressCollectionViewCell
            self.offscreenCells[reuseIdentifier] = cell
        }
        
        let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
        
        cell!.configWithType(address.type, address: address.address)
        
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
        cell!.bounds = CGRectMake(0, 0, targetWidth, cell!.bounds.height)
        cell!.contentView.bounds = cell!.bounds

        // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
        cell!.setNeedsLayout()
        cell!.layoutIfNeeded()
 
        var size = cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        // Still need to force the width, since width can be smalled due to break mode of labels
        size.width = targetWidth
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(kSectionVerticalInsets, kSectionHorizontalInsets, kSectionVerticalInsets, kSectionHorizontalInsets)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kSectionHorizontalInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kSectionVerticalInsets
    }
    
    // MARK: - Header tap gesture action
    func headerViewTapped(tapGesture: UITapGestureRecognizer) {
        var headerView = tapGesture.view as UQCollectionReusableView
        
        println("tapped header: \(headerView.indexPath)")
        
        Locator.sharedLocator.user.getPersonalInformation(PersonalInformationType.Addresses, success:{ _ in
            println("\(Locator.sharedLocator.user.personalInformation.addresses!)")
            let tappedSection = headerView.indexPath.section
            self.collectionView.reloadSections(NSIndexSet(index: tappedSection))
            }, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.PhoneNumbers, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.EmailAddresses, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.EmergencyContacts, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.DemographicInformation, success: nil, failure: nil)
//        Locator.sharedLocator.user.getPersonalInformation(User.PersonalInformation.CitizenshipImmigrationDocuments, success: nil, failure: nil)
    }
    
    // MARK: - Rotation
    // iOS7
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        logMethod()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // iOS8
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        logMethod()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Helper
    func attachTapGestureForHeaderView(headerView: UICollectionReusableView) {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "headerViewTapped:" as Selector)
        tapGesture.numberOfTouchesRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
}
