//
//  PersonalInfoImplementation.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-26.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

class PersonalInfoImplementation: MainCollectionVCImplementation {
    var sharedPersonalInformation: PersonalInformation!

    let kAddressCellReuseIdentifier = "AddressCell"
    let kNameCellResueIdentifier = "NameCell"
    let kPhoneNumberCellResueIdentifier = "PhoneNumberCell"
    let kEmailAddressCellResueIdentifier = "EmailAddressCell"
    let kEmergencyContactCellResueIdentifier = "EmergencyContactCell"
    let kDemograhicCellResueIdentifier = "DemographicCell"
    let kCitizenshipCellResueIdentifier = "CitizenshipCell"
    
    let title: String = "Personal Information"
    var mainCollectionVC: MainCollectionViewController!
    var collectionView: ZHDynamicCollectionView!
    
    init() {
        
    }
    
    func setUp(collectionVC: MainCollectionViewController) {
        // Setup
        sharedPersonalInformation = Locator.sharedLocator.user.personalInformation
        self.mainCollectionVC = collectionVC
        self.collectionView = collectionVC.collectionView
        self.registerCells()
    }
    
    func registerCells() {
        // Register cells
        var addressCellNib = UINib(nibName: "AddressCollectionViewCell", bundle: nil)
        collectionView.registerNib(addressCellNib, forCellWithReuseIdentifier: kAddressCellReuseIdentifier)
        
        collectionView.registerClass(NameCollectionViewCell.self, forCellWithReuseIdentifier: kNameCellResueIdentifier)
        collectionView.registerClass(PhoneNumberCollectionViewCell.self, forCellWithReuseIdentifier: kPhoneNumberCellResueIdentifier)
        collectionView.registerClass(EmailCollectionViewCell.self, forCellWithReuseIdentifier: kEmailAddressCellResueIdentifier)
        collectionView.registerClass(EmergencyContactCollectionViewCell.self, forCellWithReuseIdentifier: kEmergencyContactCellResueIdentifier)
        collectionView.registerClass(DemographicCollectionCell.self, forCellWithReuseIdentifier: kDemograhicCellResueIdentifier)
        collectionView.registerClass(CitizenshipCollectionViewCell.self, forCellWithReuseIdentifier: kCitizenshipCellResueIdentifier)
    }
    
    func numberOfSectionsInCollectionView() -> Int {
        return sharedPersonalInformation.categories.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        if section == mainCollectionVC.currentShowingSection {
            let choosedCase: PersonalInformationType = PersonalInformationType(rawValue: sharedPersonalInformation.categories[section])!
            switch choosedCase {
            case PersonalInformationType.Addresses:
                return sharedPersonalInformation.addresses!.count
            case PersonalInformationType.Names:
                return (sharedPersonalInformation.namesMessage == nil) ? 1 : 2
            case PersonalInformationType.PhoneNumbers:
                return sharedPersonalInformation.phoneNumbers!.count
            case PersonalInformationType.EmailAddresses:
                return sharedPersonalInformation.emailAddresses == nil ? 0 : (sharedPersonalInformation.emailAddresses?.alternateEmailAddress.count == 0 ? 2 : 4)
            case PersonalInformationType.EmergencyContacts:
                return sharedPersonalInformation.emergencyContacts!.count == 0 ? 1 : sharedPersonalInformation.emergencyContacts!.count
            case PersonalInformationType.DemographicInformation:
                return sharedPersonalInformation.demograhicInformation == nil ? 0 : sharedPersonalInformation.demograhicInformation!.keys.count + 1
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
    
    func cellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let type: PersonalInformationType = PersonalInformationType(rawValue: sharedPersonalInformation.categories[indexPath.section])!
        var cell: UICollectionViewCell!
        switch type {
        case PersonalInformationType.Addresses:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAddressCellReuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
            let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
            (cell as AddressCollectionViewCell).config(address)
            break
        case PersonalInformationType.Names:
            switch indexPath.item {
            case 0:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(kNameCellResueIdentifier, forIndexPath: indexPath) as UICollectionViewCell
                (cell as NameCollectionViewCell) .config(sharedPersonalInformation.names)
            case 1:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as UICollectionViewCell
                let description = sharedPersonalInformation.namesMessage!
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            default:
                assertionFailure("Wrong indexPath.item")
            }
        case PersonalInformationType.PhoneNumbers:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhoneNumberCellResueIdentifier, forIndexPath: indexPath) as PhoneNumberCollectionViewCell
            
            let phoneNumber: PersonalInformation.PhoneNumber = sharedPersonalInformation.phoneNumbers![indexPath.item]
            (cell as PhoneNumberCollectionViewCell).config(phoneNumber)
        case PersonalInformationType.EmailAddresses:
            switch indexPath.item {
            case 0:
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmailAddressCellResueIdentifier, forIndexPath: indexPath) as EmailCollectionViewCell
                let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                aCell.config("Campus Email Address", emails: emails)
                cell = aCell
            case 2:
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmailAddressCellResueIdentifier, forIndexPath: indexPath) as EmailCollectionViewCell
                var emails: [(String, String)] = []
                for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                    let newTuple = (eachEmail.type, eachEmail.address)
                    emails.append(newTuple)
                }
                aCell.config("Alternate Email Address", emails: emails)
                cell = aCell
            case 1, 3: // Description
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                let description = indexPath.item == 1 ? sharedPersonalInformation.emailAddresses!.campusEmailDescription : sharedPersonalInformation.emailAddresses!.alternateEmailDescription
                aCell.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
            default:
                assert(false, "Wrong indexPath.item")
            }
        case PersonalInformationType.EmergencyContacts:
            // Show message
            if sharedPersonalInformation.emergencyContacts.count == 0 {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                var message = "No current emergency contact information found."
                if let realMessage = sharedPersonalInformation.emergencyContactsMessage {
                    message = realMessage
                }
                aCell.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
            } else {
                // Show content
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmergencyContactCellResueIdentifier, forIndexPath: indexPath) as EmergencyContactCollectionViewCell
                
                let emergencyContact: PersonalInformation.EmergencyContact = sharedPersonalInformation.emergencyContacts![indexPath.item]
                aCell.config(emergencyContact)
                cell = aCell
            }
        case PersonalInformationType.DemographicInformation:
            let totalItemsCount = self.collectionView.numberOfItemsInSection(indexPath.section)
            // Last item should be description
            if indexPath.item == totalItemsCount - 1 {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
                let description = sharedPersonalInformation.demograhicInformation!.message
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            } else {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(kDemograhicCellResueIdentifier, forIndexPath: indexPath) as DemographicCollectionCell
                var demographicInfo = sharedPersonalInformation.demograhicInformation!
                let key = demographicInfo.keys[indexPath.item]
                (cell as DemographicCollectionCell).config(demographicInfo, withKey: key)
            }
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            // For non international students
            if (sharedPersonalInformation.citizenshipImmigrationDocument == nil) {
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
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

    func titleForHeaderAtIndexPath(indexPath: NSIndexPath) -> String {
        return sharedPersonalInformation.categories[indexPath.section]
    }
    
    func sizeForItemAtIndexPath(indexPath: NSIndexPath, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = collectionView.bounds.width - 2 * mainCollectionVC.kSectionHorizontalInsets
        
        let type: PersonalInformationType = PersonalInformationType(rawValue: sharedPersonalInformation.categories[indexPath.section])!
        var cell: UICollectionViewCell!
        switch type {
        case PersonalInformationType.Addresses:
            cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kAddressCellReuseIdentifier)
            let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
            (cell as AddressCollectionViewCell).config(address)
        case PersonalInformationType.Names:
            switch indexPath.item {
            case 0:
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kNameCellResueIdentifier)
                (cell as NameCollectionViewCell).config(sharedPersonalInformation.names)
            case 1:
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier)
                let description = sharedPersonalInformation.namesMessage!
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            default:
                assertionFailure("Wrong PersonalInformation Type")
            }
            
        case PersonalInformationType.PhoneNumbers:
            cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kPhoneNumberCellResueIdentifier)
            let phoneNumber: PersonalInformation.PhoneNumber = sharedPersonalInformation.phoneNumbers![indexPath.item]
            (cell as PhoneNumberCollectionViewCell).config(phoneNumber)
        case PersonalInformationType.EmailAddresses:
            switch indexPath.item {
            case 0, 2:
                // Prepare cell
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kEmailAddressCellResueIdentifier)
                if indexPath.item == 0 {
                    let emails: [(String, String)] = [("Campus Email", sharedPersonalInformation.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPersonalInformation.emailAddresses!.campusEmailAddress.deliveredTo)]
                    (cell as EmailCollectionViewCell).config("Campus Email Address", emails: emails)
                } else {
                    var emails: [(String, String)] = []
                    for eachEmail in sharedPersonalInformation.emailAddresses!.alternateEmailAddress {
                        let newTuple = (eachEmail.type, eachEmail.address)
                        emails.append(newTuple)
                    }
                    (cell as EmailCollectionViewCell).config("Alternate Email Address", emails: emails)
                }
            case 1, 3:
                // Prepare cell
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier)
                let description = indexPath.item == 1 ? sharedPersonalInformation.emailAddresses!.campusEmailDescription : sharedPersonalInformation.emailAddresses!.alternateEmailDescription
                (cell as DescriptionCollectionViewCell).configSmall(description!, textAlignment: NSTextAlignment.Left)
            default:
                assert(false, "Wrong PersonalInformation Type")
                break
            }
            break
        case PersonalInformationType.EmergencyContacts:
            // Show message
            if sharedPersonalInformation.emergencyContacts.count == 0 {
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier)
                var message = "No current emergency contact information found."
                if let realMessage = sharedPersonalInformation.emergencyContactsMessage {
                    message = realMessage
                }
                (cell as DescriptionCollectionViewCell).configLarge(message, textAlignment: NSTextAlignment.Center)
            } else {
                cell = mainCollectionVC.offscreenCells[kEmergencyContactCellResueIdentifier] as? EmergencyContactCollectionViewCell
                let emergencyContact: PersonalInformation.EmergencyContact = sharedPersonalInformation.emergencyContacts![indexPath.item]
                (cell as EmergencyContactCollectionViewCell).config(emergencyContact)
            }
        case PersonalInformationType.DemographicInformation:
            let totalItemsCount = self.collectionView.numberOfItemsInSection(indexPath.section)
            // Last item should be description
            if indexPath.item == totalItemsCount - 1 {
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier)
                let description = sharedPersonalInformation.demograhicInformation!.message
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            } else {
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(kDemograhicCellResueIdentifier)
                var demographicInfo = sharedPersonalInformation.demograhicInformation!
                let key = demographicInfo.keys[indexPath.item]
                (cell as DemographicCollectionCell).config(demographicInfo, withKey: key)
            }
        case PersonalInformationType.CitizenshipImmigrationDocuments:
            // For non international students
            if (sharedPersonalInformation.citizenshipImmigrationDocument == nil) {
                let reuseIdentifier = mainCollectionVC.kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: nil, options: nil)[0] as? DescriptionCollectionViewCell
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
                }
                var message = "No Contents"
                if let realMessage = sharedPersonalInformation.citizenshipImmigrationDocumentMessage {
                    message = realMessage
                }
                aCell!.configLarge(message, textAlignment: NSTextAlignment.Center)
                cell = aCell
            } else {
                let reuseIdentifier = kCitizenshipCellResueIdentifier
                var aCell: CitizenshipCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? CitizenshipCollectionViewCell
                if aCell == nil {
                    aCell = CitizenshipCollectionViewCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
                
        var size = cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        // Still need to force the width, since width can be smalled due to break mode of labels
        size.width = targetWidth
        return size
    }
    
    func headerViewTapped(headerView: UQCollectionReusableView) {
        let tappedCase: PersonalInformationType = PersonalInformationType(rawValue: sharedPersonalInformation.categories[headerView.indexPath.section])!
        println("tapped header: \(tappedCase.rawValue)")
        
        mainCollectionVC.showHud(nil)
        
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
}