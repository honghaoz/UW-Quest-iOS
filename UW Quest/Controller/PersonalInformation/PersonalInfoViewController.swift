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
    let kDescriptionCellResueIdentifier = "DescriptionCell"
    let kEmergencyContactCellResueIdentifier = "EmergencyContactCell"
    let kDemograhicCellResueIdentifier = "DemographicCell"
    let kCitizenshipCellResueIdentifier = "CitizenshipCell"

    var currentShowingSection: Int = -1
    
    // A dictionary of offscreen cells that are used within the sizeForItemAtIndexPath method to handle the size calculations. These are never drawn onscreen. The dictionary is in the format:
    // { NSString *reuseIdentifier : UICollectionViewCell *offscreenCell, ... }
    var offscreenCells = Dictionary<String, UICollectionViewCell>();
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Personal Information"
//        // Default animation
//        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)

        // Dynamic transition
        var dynamicTransition = Locator.sharedLocator.dynamicTransition
        dynamicTransition.slidingViewController = self.slidingViewController()
        self.slidingViewController().delegate = dynamicTransition
        
        self.slidingViewController().topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesture.Tapping | ECSlidingViewControllerAnchoredGesture.Custom
        
        var dynamicTransitionPanGesture = UIPanGestureRecognizer(target: dynamicTransition, action: "handlePanGesture:")
        self.slidingViewController().customAnchoredGestures = [dynamicTransitionPanGesture]
        self.navigationController?.view.addGestureRecognizer(dynamicTransitionPanGesture)
        
//        // Zoom transition
//        let zoomTransition = Locator.sharedLocator.zoomTransition
//        self.slidingViewController().delegate = zoomTransition
//        self.slidingViewController().topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesture.Tapping | ECSlidingViewControllerAnchoredGesture.Panning
//        
//        self.navigationController?.view.addGestureRecognizer(self.slidingViewController().panGesture)
        
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
        
        var descriptionCellNib = UINib(nibName: "DescriptionCollectionViewCell", bundle: nil)
        collectionView.registerNib(descriptionCellNib, forCellWithReuseIdentifier: kDescriptionCellResueIdentifier)
        
        collectionView.registerClass(EmergencyContactCollectionViewCell.self, forCellWithReuseIdentifier: kEmergencyContactCellResueIdentifier)
        collectionView.registerClass(DemographicCollectionCell.self, forCellWithReuseIdentifier: kDemograhicCellResueIdentifier)
        collectionView.registerClass(CitizenshipCollectionViewCell.self, forCellWithReuseIdentifier: kCitizenshipCellResueIdentifier)
        
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
                return sharedPersonalInformation.emailAddresses == nil ? 0 : (sharedPersonalInformation.emailAddresses?.alternateEmailAddress.count == 0 ? 2 : 4)
            case PersonalInformationType.EmergencyContacts:
                return sharedPersonalInformation.emergencyContacts!.count == 0 ? 1 : sharedPersonalInformation.emergencyContacts!.count
            case PersonalInformationType.DemographicInformation:
                return sharedPersonalInformation.demograhicInformation == nil ? 0 : (3 + (sharedPersonalInformation.demograhicInformation!.visaOrPermitData != nil ? 1 : 0) + sharedPersonalInformation.demograhicInformation!.nationalIdNumbers!.count)
            case PersonalInformationType.CitizenshipImmigrationDocuments:
                return sharedPersonalInformation.citizenshipImmigrationDocument == nil ? 1 : ((sharedPersonalInformation.citizenshipImmigrationDocument!.requiredDocumentation.count > 0 ? 1 : 0) + (sharedPersonalInformation.citizenshipImmigrationDocument!.pastDocumentation.count > 0 ? 1 : 0))
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
                let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered To", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                aCell.config("Campus Email Address", emails: emails)
                cell = aCell
                break
            case 2:
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmailAddressCellResueIdentifier, forIndexPath: indexPath) as EmailCollectionViewCell
                var emails: [(String, String)] = []
                for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                    let newTuple = (eachEmail.type, eachEmail.address)
                    emails.append(newTuple)
                }
                aCell.config("Alternate Email Address", emails: emails)
                cell = aCell
                break
            case 1, 3: // Description
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                let description = indexPath.item == 1 ? sharedPersonalInformation.emailAddresses!.campusEmailDescription : sharedPersonalInformation.emailAddresses!.alternateEmailDescription
                aCell.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
                break
            default:
                assert(false, "Wrong indexPath.item")
                break
            }
            break
        case PersonalInformationType.EmergencyContacts:
            // Show message
            if sharedPersonalInformation.emergencyContacts.count == 0 {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                var message = "No current emergency contact information found."
                if let realMessage = sharedPersonalInformation.emergencyContactsMessage {
                    message = realMessage
                }
                aCell.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
                break
            }
            // Show content
            var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmergencyContactCellResueIdentifier, forIndexPath: indexPath) as EmergencyContactCollectionViewCell
            
            let emergencyContact: PersonalInformation.EmergencyContact = sharedPersonalInformation.emergencyContacts![indexPath.item]
            aCell.config(emergencyContact)
            cell = aCell
            break
        case PersonalInformationType.DemographicInformation:
            let nationalIdsCount = sharedPersonalInformation.demograhicInformation!.nationalIdNumbers!.count
            let totalItemsCount = self.collectionView.numberOfItemsInSection(indexPath.section)
            // Last item should be description
            if indexPath.item == totalItemsCount - 1 {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                let description = sharedPersonalInformation.demograhicInformation?.note!
                aCell.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
            } else {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kDemograhicCellResueIdentifier, forIndexPath: indexPath) as DemographicCollectionCell
                var demographicInfo = sharedPersonalInformation.demograhicInformation!
                if indexPath.item == 0 {
                    aCell.configDemographicInformation(demographicInfo)
                } else if indexPath.item <= nationalIdsCount {
                    aCell.configNationalIds(demographicInfo, index: indexPath.item - 1)
                } else if indexPath.item == totalItemsCount - 2 && (sharedPersonalInformation.demograhicInformation!.visaOrPermitData != nil) {
                    aCell.configVisa(demographicInfo)
                } else {
                    aCell.configCitizenship(demographicInfo)
                }
                cell = aCell
            }
            break
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            // For non international students
            if (sharedPersonalInformation.citizenshipImmigrationDocument == nil) {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                var message = "No Contents"
                if let realMessage = sharedPersonalInformation.citizenshipImmigrationDocumentMessage {
                    message = realMessage
                }
                aCell.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
            } else {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCitizenshipCellResueIdentifier, forIndexPath: indexPath) as CitizenshipCollectionViewCell
                if indexPath.item == 0 {
                    aCell.configRequiredDoc(self.sharedPersonalInformation.citizenshipImmigrationDocument!)
                } else if indexPath.item == 1 {
                    aCell.configPastDoc(self.sharedPersonalInformation.citizenshipImmigrationDocument!)
                } else {
                    assert(false, "Wrong CitizenshipImmigrationDocuments row")
                }
                cell = aCell
            }
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
            switch indexPath.item {
            case 0, 2:
                // Prepare cell
                let reuseIdentifier = kEmailAddressCellResueIdentifier
                var aCell: EmailCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? EmailCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("EmailCollectionViewCell", owner: self, options: nil)[0] as? EmailCollectionViewCell
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                
                if indexPath.item == 0 {
                    let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                    aCell!.config("Campus Email Address", emails: emails)
                    cell = aCell
                } else {
                    var emails: [(String, String)] = []
                    for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                        let newTuple = (eachEmail.type, eachEmail.address)
                        emails.append(newTuple)
                    }
                    aCell!.config("Alternate Email Address", emails: emails)
                    cell = aCell
                }
                break
            case 1, 3:
                // Prepare cell
                let reuseIdentifier = kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: self, options: nil)[0] as? DescriptionCollectionViewCell
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                
                let description = indexPath.item == 1 ? sharedPersonalInformation.emailAddresses!.campusEmailDescription : sharedPersonalInformation.emailAddresses!.alternateEmailDescription
                aCell!.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
                break
            default:
                assert(false, "Wrong PersonalInformation Type")
                break
            }
            break
        case PersonalInformationType.EmergencyContacts:
            // Show message
            if sharedPersonalInformation.emergencyContacts.count == 0 {
                let reuseIdentifier = kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: self, options: nil)[0] as? DescriptionCollectionViewCell
                    self.offscreenCells[reuseIdentifier] = aCell
                }

                var message = "No current emergency contact information found."
                if let realMessage = sharedPersonalInformation.emergencyContactsMessage {
                    message = realMessage
                }
                aCell!.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
                break
            }
            
            let reuseIdentifier = kEmergencyContactCellResueIdentifier
            var aCell: EmergencyContactCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? EmergencyContactCollectionViewCell
            if aCell == nil {
                aCell = EmergencyContactCollectionViewCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                self.offscreenCells[reuseIdentifier] = aCell
            }
            
            let emergencyContact: PersonalInformation.EmergencyContact = sharedPersonalInformation.emergencyContacts![indexPath.item]
            aCell!.config(emergencyContact)
            cell = aCell
            break
        case PersonalInformationType.DemographicInformation:
            let nationalIdsCount = sharedPersonalInformation.demograhicInformation!.nationalIdNumbers!.count
            let totalItemsCount = self.collectionView.numberOfItemsInSection(indexPath.section)
            // Last item should be description
            if indexPath.item == totalItemsCount - 1 {
                let reuseIdentifier = kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: self, options: nil)[0] as? DescriptionCollectionViewCell
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                let description = sharedPersonalInformation.demograhicInformation?.note!
                aCell!.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
            } else {
                let reuseIdentifier = kDemograhicCellResueIdentifier
                var aCell: DemographicCollectionCell? = self.offscreenCells[reuseIdentifier] as? DemographicCollectionCell
                if aCell == nil {
                    aCell = DemographicCollectionCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                var demographicInfo = sharedPersonalInformation.demograhicInformation!
                if indexPath.item == 0 {
                    aCell!.configDemographicInformation(demographicInfo)
                } else if indexPath.item <= nationalIdsCount {
                    aCell!.configNationalIds(demographicInfo, index: indexPath.item - 1)
                } else if (indexPath.item == totalItemsCount - 2) && (sharedPersonalInformation.demograhicInformation!.visaOrPermitData != nil) {
                    aCell!.configVisa(demographicInfo)
                } else {
                    aCell!.configCitizenship(demographicInfo)
                }
                cell = aCell
            }
            break
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            // For non international students
            if (sharedPersonalInformation.citizenshipImmigrationDocument == nil) {
                let reuseIdentifier = kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: self, options: nil)[0] as? DescriptionCollectionViewCell
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                var message = "No Contents"
                if let realMessage = sharedPersonalInformation.citizenshipImmigrationDocumentMessage {
                    message = realMessage
                }
                aCell!.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
            } else {
                let reuseIdentifier = kCitizenshipCellResueIdentifier
                var aCell: CitizenshipCollectionViewCell? = self.offscreenCells[reuseIdentifier] as? CitizenshipCollectionViewCell
                if aCell == nil {
                    aCell = CitizenshipCollectionViewCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                    self.offscreenCells[reuseIdentifier] = aCell
                }
                if indexPath.item == 0 {
                    aCell!.configRequiredDoc(self.sharedPersonalInformation.citizenshipImmigrationDocument!)
                } else if indexPath.item == 1 {
                    aCell!.configPastDoc(self.sharedPersonalInformation.citizenshipImmigrationDocument!)
                } else {
                    assert(false, "Wrong CitizenshipImmigrationDocuments row")
                }
                cell = aCell
            }
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
                println("emergency count: \(self.sharedPersonalInformation.emergencyContacts.count)")
                break
            case PersonalInformationType.DemographicInformation:
                println("demographic: \(self.sharedPersonalInformation.demograhicInformation != nil)")
                break
            case PersonalInformationType.CitizenshipImmigrationDocuments:
                println("citizenshipDoc: \(self.sharedPersonalInformation.citizenshipImmigrationDocument)")
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
            
            }, failure: {errorMessage, error in
//                JGProgressHUD.dismiss(0, animated: true)
                JGProgressHUD.showFailure(errorMessage, duration: 0.5)
        })
    }
    
    // MARK: - Rotation
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
