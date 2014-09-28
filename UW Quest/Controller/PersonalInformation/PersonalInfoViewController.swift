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
//    let kPhoneNumberCellResueIdentifier = "PhoneNumberCell"
//    let kEmailAddressCellResueIdentifier = "EmailAddressCell"
//    let kEmergencyContactCellResueIdentifier = "EmergencyContactCell"
//    let kDemograhicCellResueIdentifier = "DemographicCell"
//    let kCitizenshipCellResueIdentifier = "CitizenshipCell"

    var currentShowingSection: Int = -1
    
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
        var nameCellNib = UINib(nibName: "NameCollectionViewCell", bundle: nil)
        collectionView.registerNib(nameCellNib, forCellWithReuseIdentifier: kNameCellResueIdentifier)
        
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
            aCell.configWithType(address.type, address: address.address)
            cell = aCell
            break
        case PersonalInformationType.Names:
            var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kNameCellResueIdentifier, forIndexPath: indexPath) as NameCollectionViewCell
            
            let name: PersonalInformation.Name = sharedPersonalInformation.names![indexPath.item]
            aCell.configWithType(name.nameType, firstName: name.firstName, middleName: name.middleName, lastName: name.lastName, namePrefix: name.namePrefix, nameSuffix: name.nameSuffix)
            cell = aCell
            break
        case PersonalInformationType.PhoneNumbers:
            break
        case PersonalInformationType.EmailAddresses:
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
            
            aCell!.configWithType(address.type, address: address.address)
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
            aCell!.configWithType(name.nameType, firstName: name.firstName, middleName: name.middleName, lastName: name.lastName, namePrefix: name.namePrefix, nameSuffix: name.nameSuffix)
            cell = aCell
            break
        case PersonalInformationType.PhoneNumbers:
            break
        case PersonalInformationType.EmailAddresses:
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
        
        Locator.sharedLocator.user.getPersonalInformation(tappedCase, success:{ _ in
            switch tappedCase {
            case PersonalInformationType.Addresses:
                println("addresses count: \(self.sharedPersonalInformation.addresses.count)")
                break
            case PersonalInformationType.Names:
                println("names count: \(self.sharedPersonalInformation.names.count)")
                break
            case PersonalInformationType.PhoneNumbers:
                break
            case PersonalInformationType.EmailAddresses:
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
            
            }, failure: nil)
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
