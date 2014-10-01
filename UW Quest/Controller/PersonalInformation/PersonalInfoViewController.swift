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
    
    let kHeaderViewReuseIdentifier = "HeaderView"
    let kAddressCellReuseIdentifier = "AddressCell"
    let kNameCellResueIdentifier = "NameCell"
    let kPhoneNumberCellResueIdentifier = "PhoneNumberCell"
    let kEmailAddressCellResueIdentifier = "EmailAddressCell"
    let kEmailAddressDescriptionCellResueIdentifier = "EmailAddressDescriptionCell"
//    let kEmergencyContactCellResueIdentifier = "EmergencyContactCell"
//    let kDemograhicCellResueIdentifier = "DemographicCell"
//    let kCitizenshipCellResueIdentifier = "CitizenshipCell"

    var currentShowingSection: Int = -1
    
    // A dictionary of offscreen cells that are used within the sizeForItemAtIndexPath method to handle the size calculations. These are never drawn onscreen. The dictionary is in the format:
    // { NSString *reuseIdentifier : UICollectionViewCell *offscreenCell, ... }
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
        var nameCellNib = UINib(nibName: "NameCollectionViewCell", bundle: nil)
        collectionView.registerNib(nameCellNib, forCellWithReuseIdentifier: kNameCellResueIdentifier)
        var phoneNumberCellNib = UINib(nibName: "PhoneNumberCollectionViewCell", bundle: nil)
        collectionView.registerNib(phoneNumberCellNib, forCellWithReuseIdentifier: kPhoneNumberCellResueIdentifier)
        var emailCellNib = UINib(nibName: "EmailCollectionViewCell", bundle: nil)
        collectionView.registerNib(emailCellNib, forCellWithReuseIdentifier: kEmailAddressCellResueIdentifier)
        var emailDescriptionCellNib = UINib(nibName: "DescriptionCollectionViewCell", bundle: nil)
        collectionView.registerNib(emailDescriptionCellNib, forCellWithReuseIdentifier: kEmailAddressDescriptionCellResueIdentifier)
        
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
        if section == currentShowingSection {
            let choosedCase: PersonalInformationType = PersonalInformationType.fromRaw(sharedPersonalInformation.categories[section])!
            switch choosedCase {
            case PersonalInformationType.Addresses:
                return sharedPersonalInformation.addresses!.count
            case PersonalInformationType.Names:
                return sharedPersonalInformation.names!.count
            case PersonalInformationType.PhoneNumbers:
                return sharedPersonalInformation.phoneNumbers!.count
            case PersonalInformationType.EmailAddresses:
                println("return \(sharedPersonalInformation.emailAddresses == nil ? 0 : 2)")
                return sharedPersonalInformation.emailAddresses == nil ? 0 : 2
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
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let type: PersonalInformationType = PersonalInformationType.fromRaw(sharedPersonalInformation.categories[indexPath.section])!
        var cell: UICollectionViewCell!
        switch type {
        case PersonalInformationType.Addresses:
            var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as AddressCollectionViewCell
            
            let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
            aCell.config(address)
            cell = aCell
            break
        case PersonalInformationType.Names:
            var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kNameCellResueIdentifier, forIndexPath: indexPath) as NameCollectionViewCell
            
            let name: PersonalInformation.Name = sharedPersonalInformation.names![indexPath.item]
            aCell.config(name)
            cell = aCell
            break
        case PersonalInformationType.PhoneNumbers:
            var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhoneNumberCellResueIdentifier, forIndexPath: indexPath) as PhoneNumberCollectionViewCell
            
            let phoneNumber: PersonalInformation.PhoneNumber = sharedPersonalInformation.phoneNumbers![indexPath.item]
            aCell.config(phoneNumber)
            cell = aCell
            break
        case PersonalInformationType.EmailAddresses:
            switch indexPath.item {
            case 0:
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmailAddressCellResueIdentifier, forIndexPath: indexPath) as EmailCollectionViewCell
                let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                aCell.config("Campus Email Address", emails: emails)
                cell = aCell
                break
            case 1:
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmailAddressCellResueIdentifier, forIndexPath: indexPath) as EmailCollectionViewCell
                var emails: [(String, String)] = []
                for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                    let newTuple = (eachEmail.type, eachEmail.address)
                    emails.append(newTuple)
                }
                aCell.config("Alternate Email Address", emails: emails)
                cell = aCell
                break
            default:
                break
            }
            break
        case PersonalInformationType.EmergencyContacts:
            break
        case PersonalInformationType.DemographicInformation:
            break
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            break
        default:
            assert(false, "Wrong PersonalInformation Type")
            break
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var headerView: UQCollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kHeaderViewReuseIdentifier, forIndexPath: indexPath) as UQCollectionReusableView
        
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
        
        headerView.titleLabel.text = sharedPersonalInformation.categories[indexPath.section]
        
        return headerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = collectionView.bounds.width - 2 * kSectionHorizontalInsets
        
        let type: PersonalInformationType = PersonalInformationType.fromRaw(sharedPersonalInformation.categories[indexPath.section])!
        var cell: UICollectionViewCell!
        switch type {
        case PersonalInformationType.Addresses:
            // Use fake cell to calculate height
            let reuseIdentifier = kAddressCellReuseIdentifier
            var aCell: AddressCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? AddressCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("AddressCollectionViewCell", owner: self, options: nil)[0] as? AddressCollectionViewCell
                self.offscreenCells[reuseIdentifier] = aCell
            }
            
            let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
            aCell!.config(address)
            cell = aCell
            break
        case PersonalInformationType.Names:
            // Use fake cell to calculate height
            let reuseIdentifier = kNameCellResueIdentifier
            var aCell: NameCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? NameCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("NameCollectionViewCell", owner: self, options: nil)[0] as? NameCollectionViewCell
                self.offscreenCells[reuseIdentifier] = aCell
            }
            
            let name: PersonalInformation.Name = sharedPersonalInformation.names![indexPath.item]
            aCell!.config(name)
            cell = aCell
            break
        case PersonalInformationType.PhoneNumbers:
            let reuseIdentifier = kPhoneNumberCellResueIdentifier
            var aCell: PhoneNumberCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? PhoneNumberCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("PhoneNumberCollectionViewCell", owner: self, options: nil)[0] as? PhoneNumberCollectionViewCell
                self.offscreenCells[reuseIdentifier] = aCell
            }
            
            let phoneNumber: PersonalInformation.PhoneNumber = sharedPersonalInformation.phoneNumbers![indexPath.item]
            aCell!.config(phoneNumber)
            cell = aCell
            break
        case PersonalInformationType.EmailAddresses:
            let reuseIdentifier = kEmailAddressCellResueIdentifier
            var aCell: EmailCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? EmailCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("EmailCollectionViewCell", owner: self, options: nil)[0] as? EmailCollectionViewCell
                self.offscreenCells[reuseIdentifier] = aCell
            }
            
            switch indexPath.item {
            case 0:
                let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                aCell!.config("Campus Email Address", emails: emails)
                cell = aCell
                break
            case 1:
                var emails: [(String, String)] = []
                for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                    let newTuple = (eachEmail.type, eachEmail.address)
                    emails.append(newTuple)
                }
                aCell!.config("Alternate Email Address", emails: emails)
                cell = aCell
                break
            default:
                break
            }
            break
        case PersonalInformationType.EmergencyContacts:
            break
        case PersonalInformationType.DemographicInformation:
            break
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            break
        default:
            assert(false, "Wrong PersonalInformation Type")
            break
        }
        
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
    
    // MARK: - Header tap gesture action
    func headerViewTapped(tapGesture: UITapGestureRecognizer) {
        var headerView = tapGesture.view as UQCollectionReusableView
        currentShowingSection = currentShowingSection == headerView.indexPath.section ? -1 : headerView.indexPath.section
        
        let tappedCase: PersonalInformationType = PersonalInformationType.fromRaw(sharedPersonalInformation.categories[headerView.indexPath.section])!
        println("tapped header: \(tappedCase.toRaw())")
        
        self.showHud(nil)
        
        Locator.sharedLocator.user.getPersonalInformation(tappedCase, success:{ _ in
            JGProgressHUD.dismiss(0, animated: true)
            switch tappedCase {
            case PersonalInformationType.Addresses:
                println("addresses count: \(self.sharedPersonalInformation.addresses.count)")
                break
            case PersonalInformationType.Names:
                println("names count: \(self.sharedPersonalInformation.names.count)")
                break
            case PersonalInformationType.PhoneNumbers:
                println("phoneNumbers count: \(self.sharedPersonalInformation.phoneNumbers.count)")
                break
            case PersonalInformationType.EmailAddresses:
                println("emails: \(self.sharedPersonalInformation.emailAddresses != nil)")
                break
            case PersonalInformationType.EmergencyContacts:
                break
            case PersonalInformationType.DemographicInformation:
                break
            case PersonalInformationType.CitizenshipImmigrationDocuments:
                break
            default:
                assert(false, "Wrong PersonalInformation Type")
            }

            // Refresh tapped section
//            let tappedSection = headerView.indexPath.section
//            self.collectionView.reloadSections(NSIndexSet(index: tappedSection))
//            
            self.collectionView.reloadData()
//            // Refresh other sections
//            self.collectionView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: self.numberOfSectionsInCollectionView(self.collectionView))))
//            self.collectionView.collectionViewLayout.invalidateLayout()
//            self.collectionView.scrollToItemAtIndexPath(headerView.indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
            
            }, failure: {_ in
                JGProgressHUD.dismiss(0, animated: true)
        })
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
