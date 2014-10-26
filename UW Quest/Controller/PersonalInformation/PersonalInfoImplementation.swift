//
//  PersonalInfoImplementation.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-26.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

class PersonalInfoImplementation {
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
    var collectionView: UICollectionView!
   
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
        var nameCellNib = UINib(nibName: "NameCollectionViewCell", bundle: nil)
        collectionView.registerNib(nameCellNib, forCellWithReuseIdentifier: kNameCellResueIdentifier)
        var phoneNumberCellNib = UINib(nibName: "PhoneNumberCollectionViewCell", bundle: nil)
        collectionView.registerNib(phoneNumberCellNib, forCellWithReuseIdentifier: kPhoneNumberCellResueIdentifier)
        var emailCellNib = UINib(nibName: "EmailCollectionViewCell", bundle: nil)
        collectionView.registerNib(emailCellNib, forCellWithReuseIdentifier: kEmailAddressCellResueIdentifier)
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
    
    func cellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let type: PersonalInformationType = PersonalInformationType(rawValue: sharedPersonalInformation.categories[indexPath.section])!
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
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
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
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
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
                var aCell = collectionView.dequeueReusableCellWithReuseIdentifier(mainCollectionVC.kDescriptionCellResueIdentifier, forIndexPath: indexPath) as DescriptionCollectionViewCell
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
            // Use fake cell to calculate height
            let reuseIdentifier = kAddressCellReuseIdentifier
            var aCell: AddressCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? AddressCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("AddressCollectionViewCell", owner: nil, options: nil)[0] as? AddressCollectionViewCell
                mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
            }
            
            let address: PersonalInformation.Address = sharedPersonalInformation.addresses![indexPath.item]
            aCell!.config(address)
            cell = aCell
            break
        case PersonalInformationType.Names:
            // Use fake cell to calculate height
            let reuseIdentifier = kNameCellResueIdentifier
            var aCell: NameCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? NameCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("NameCollectionViewCell", owner: nil, options: nil)[0] as? NameCollectionViewCell
                mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
            }
            
            let name: PersonalInformation.Name = sharedPersonalInformation.names![indexPath.item]
            aCell!.config(name)
            cell = aCell
            break
        case PersonalInformationType.PhoneNumbers:
            let reuseIdentifier = kPhoneNumberCellResueIdentifier
            var aCell: PhoneNumberCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? PhoneNumberCollectionViewCell
            if aCell == nil {
                aCell = NSBundle.mainBundle().loadNibNamed("PhoneNumberCollectionViewCell", owner: nil, options: nil)[0] as? PhoneNumberCollectionViewCell
                mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
                var aCell: EmailCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? EmailCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("EmailCollectionViewCell", owner: nil, options: nil)[0] as? EmailCollectionViewCell
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
                let reuseIdentifier = mainCollectionVC.kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: nil, options: nil)[0] as? DescriptionCollectionViewCell
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
                let reuseIdentifier = mainCollectionVC.kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: nil, options: nil)[0] as? DescriptionCollectionViewCell
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
            var aCell: EmergencyContactCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? EmergencyContactCollectionViewCell
            if aCell == nil {
                aCell = EmergencyContactCollectionViewCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
                let reuseIdentifier = mainCollectionVC.kDescriptionCellResueIdentifier
                var aCell: DescriptionCollectionViewCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? DescriptionCollectionViewCell
                if aCell == nil {
                    aCell = NSBundle.mainBundle().loadNibNamed("DescriptionCollectionViewCell", owner: nil, options: nil)[0] as? DescriptionCollectionViewCell
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
                }
                let description = sharedPersonalInformation.demograhicInformation?.note!
                aCell!.configSmall(description!, textAlignment: NSTextAlignment.Left)
                cell = aCell
            } else {
                let reuseIdentifier = kDemograhicCellResueIdentifier
                var aCell: DemographicCollectionCell? = mainCollectionVC.offscreenCells[reuseIdentifier] as? DemographicCollectionCell
                if aCell == nil {
                    aCell = DemographicCollectionCell(frame: CGRectMake(0, 0, targetWidth, targetWidth))
                    mainCollectionVC.offscreenCells[reuseIdentifier] = aCell
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
        
        // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
        cell!.setNeedsLayout()
        cell!.layoutIfNeeded()
        
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