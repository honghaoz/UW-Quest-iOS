//
//  PersonalInfoImplementation.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-26.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

class PersonalInfoImplementation: MainCollectionVCImplementation {
    var sharedPI: PersonalInformation = Locator.user.personalInformation

    let kAddressCellIdentifier = "AddressCell"
    let kNameCellIdentifier = "NameCell"
    let kPhoneNumberCellIdentifier = "PhoneNumberCell"
    let kEmailAddressCellIdentifier = "EmailAddressCell"
    let kEmergencyContactCellIdentifier = "EmergencyContactCell"
    let kDemograhicCellIdentifier = "DemographicCell"
    let kCitizenshipCellIdentifier = "CitizenshipCell"
    
    let title: String = "Personal Information"
    var mainCollectionVC: MainCollectionViewController!
    var collectionView: ZHDynamicCollectionView!
    
    init() {
        
    }
    
    func setUp(collectionVC: MainCollectionViewController) {
        // Setup
        mainCollectionVC = collectionVC
        collectionView = collectionVC.collectionView
        registerCells()
    }
    
    func registerCells() {
        // Register cells
        var addressCellNib = UINib(nibName: "AddressCollectionViewCell", bundle: nil)
        collectionView.registerNib(addressCellNib, forCellWithReuseIdentifier: kAddressCellIdentifier)
        
        collectionView.registerClass(NameCollectionViewCell.self, forCellWithReuseIdentifier: kNameCellIdentifier)
        collectionView.registerClass(PhoneNumberCollectionViewCell.self, forCellWithReuseIdentifier: kPhoneNumberCellIdentifier)
        collectionView.registerClass(EmailCollectionViewCell.self, forCellWithReuseIdentifier: kEmailAddressCellIdentifier)
        collectionView.registerClass(EmergencyContactCollectionViewCell.self, forCellWithReuseIdentifier: kEmergencyContactCellIdentifier)
        collectionView.registerClass(DemographicCollectionCell.self, forCellWithReuseIdentifier: kDemograhicCellIdentifier)
        collectionView.registerClass(CitizenshipCollectionViewCell.self, forCellWithReuseIdentifier: kCitizenshipCellIdentifier)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView() -> Int {
        return sharedPI.categories.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        if section == mainCollectionVC.currentShowingSection {
            let choosedCase: PersonalInformationType = PersonalInformationType(rawValue: sharedPI.categories[section])!
            switch choosedCase {
            case .Addresses:
                return sharedPI.addresses!.count
            case .Names:
                return (sharedPI.namesMessage == nil) ? 1 : 2
            case .PhoneNumbers:
                return sharedPI.phoneNumbers!.count
            case .EmailAddresses:
                return sharedPI.emailAddresses == nil ? 0 : (sharedPI.emailAddresses?.alternateEmailAddress.count == 0 ? 2 : 4)
            case .EmergencyContacts:
                return sharedPI.emergencyContacts!.count == 0 ? 1 : sharedPI.emergencyContacts!.count
            case .DemographicInformation:
                return sharedPI.demograhicInformation == nil ? 0 : sharedPI.demograhicInformation!.keys.count + 1
            case .CitizenshipImmigrationDocuments:
                return sharedPI.citizenshipImmigrationDocument == nil ? 1 : sharedPI.citizenshipImmigrationDocument!.docs.count == 0 ? 1 : sharedPI.citizenshipImmigrationDocument!.docs.count
            default:
                assert(false, "Wrong PersonalInformation Type")
                return 0
            }
        } else {
            return 0
        }
    }
    
    func cellForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = dequeueAndConfigCell(.CellFor, indexPath: indexPath)
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    
    // MARK: - UICollectionViewFlowLayout Delegate
    func sizeForItemAtIndexPath(indexPath: NSIndexPath, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = collectionView.bounds.width - 2 * mainCollectionVC.kSectionHorizontalInsets
        
        var cell = dequeueAndConfigCell(.SizeFor, indexPath: indexPath)
        
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
        cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
        cell.contentView.bounds = cell.bounds
                
        var size = cell.contentView.systemLayoutSizeFittingSize(CGSizeMake(targetWidth, cell.bounds.height))
        // Still need to force the width, since width can be smalled due to break mode of labels
        if abs(size.width - targetWidth) > 1 {
            size.width = targetWidth
        }
        return size
    }
    
    // MARK: UICollectionView Helper
    
    /**
    Dequeue a proper cell for sizeFor/CellFor and make a configuration for this cell
    This method is for consolidating configurations for sizeForCell and cellFor..
    
    :param: dequeueType calling function, e.g. size for / cell for
    :param: indexPath   indexPath for cell
    
    :returns: configured UICollectionViewCell
    */
    private func dequeueAndConfigCell(dequeueType: UICollectionView.DequeueCellFunctionType, indexPath: NSIndexPath) -> UICollectionViewCell {
        
        /**
        Dequeue a cell according to cell identifier and deque function type
        
        :param: identifier  cell identifier
        :param: dequeueType calling function, e.g. size for / cell for
        :param: indexPath   indexPath for this cell
        
        :returns: UICollectionCell
        */
        func dequeueCell(identifier: String, dequeueType: UICollectionView.DequeueCellFunctionType, indexPath: NSIndexPath) -> UICollectionViewCell {
            var cell: UICollectionViewCell!
            switch dequeueType {
            case .SizeFor:
                cell = collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(identifier)
            case .CellFor:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as UICollectionViewCell
            }
            return cell
        }
        
        let piType: PersonalInformationType = PersonalInformationType(rawValue: sharedPI.categories[indexPath.section])!
        var cell: UICollectionViewCell!
        
        // Dequeue cell and make configuration
        switch piType {
        case .Addresses:
            cell = dequeueCell(kAddressCellIdentifier, dequeueType, indexPath)
            let address: PersonalInformation.Address = sharedPI.addresses![indexPath.item]
            (cell as AddressCollectionViewCell).config(address)
        case .Names:
            switch indexPath.item {
            case 0:
                cell = dequeueCell(kNameCellIdentifier, dequeueType, indexPath)
                (cell as NameCollectionViewCell).config(sharedPI.names)
            case 1:
                cell = dequeueCell(mainCollectionVC.kDescriptionCellResueIdentifier, dequeueType, indexPath)
                let description = sharedPI.namesMessage!
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            default:
                assertionFailure("Wrong PersonalInformation Type")
            }
        case .PhoneNumbers:
            cell = dequeueCell(kPhoneNumberCellIdentifier, dequeueType, indexPath)
            let phoneNumber: PersonalInformation.PhoneNumber = sharedPI.phoneNumbers![indexPath.item]
            (cell as PhoneNumberCollectionViewCell).config(phoneNumber)
        case .EmailAddresses:
            switch indexPath.item {
            case 0:
                cell = dequeueCell(kEmailAddressCellIdentifier, dequeueType, indexPath)
                let emails: [(String, String)] = [("Campus Email", sharedPI.emailAddresses!.campusEmailAddress.campusEmail), ("Delivered to", sharedPI.emailAddresses!.campusEmailAddress.deliveredTo)]
                (cell as EmailCollectionViewCell).config("Campus Email Address", emails: emails)
            case 2:
                cell = dequeueCell(kEmailAddressCellIdentifier, dequeueType, indexPath)
                var emails: [(String, String)] = []
                for eachEmail in sharedPI.emailAddresses!.alternateEmailAddress {
                    let newTuple = (eachEmail.type, eachEmail.address)
                    emails.append(newTuple)
                }
                (cell as EmailCollectionViewCell).config("Alternate Email Address", emails: emails)
            case 1, 3:
                cell = dequeueCell(mainCollectionVC.kDescriptionCellResueIdentifier, dequeueType, indexPath)
                let description = indexPath.item == 1 ? sharedPI.emailAddresses!.campusEmailDescription : sharedPI.emailAddresses!.alternateEmailDescription
                (cell as DescriptionCollectionViewCell).configSmall(description!, textAlignment: NSTextAlignment.Left)
            default:
                assert(false, "Wrong PersonalInformation Type")
            }
        case .EmergencyContacts:
            // Show message
            if sharedPI.emergencyContacts.count == 0 {
                cell = dequeueCell(mainCollectionVC.kDescriptionCellResueIdentifier, dequeueType, indexPath)
                var message = "No current emergency contact information found."
                if let realMessage = sharedPI.emergencyContactsMessage {
                    message = realMessage
                }
                (cell as DescriptionCollectionViewCell).configLarge(message, textAlignment: NSTextAlignment.Center)
            } else {
                cell = dequeueCell(kEmergencyContactCellIdentifier, dequeueType, indexPath)
                let emergencyContact: PersonalInformation.EmergencyContact = sharedPI.emergencyContacts![indexPath.item]
                (cell as EmergencyContactCollectionViewCell).config(emergencyContact)
            }
        case .DemographicInformation:
            let totalItemsCount = self.collectionView.numberOfItemsInSection(indexPath.section)
            // Last item should be description
            if indexPath.item == totalItemsCount - 1 {
                cell = dequeueCell(mainCollectionVC.kDescriptionCellResueIdentifier, dequeueType, indexPath)
                let description = sharedPI.demograhicInformation!.message
                (cell as DescriptionCollectionViewCell).configSmall(description, textAlignment: NSTextAlignment.Left)
            } else {
                cell = dequeueCell(kDemograhicCellIdentifier, dequeueType, indexPath)
                var demographicInfo = sharedPI.demograhicInformation!
                let key = demographicInfo.keys[indexPath.item]
                (cell as DemographicCollectionCell).config(demographicInfo, withKey: key)
            }
        case .CitizenshipImmigrationDocuments:
            // For non international students
            if (sharedPI.citizenshipImmigrationDocument == nil || sharedPI.citizenshipImmigrationDocument!.docs.count == 0) {
                cell = dequeueCell(mainCollectionVC.kDescriptionCellResueIdentifier, dequeueType, indexPath)
                (cell as DescriptionCollectionViewCell).configLarge("No Documents", textAlignment: NSTextAlignment.Center)
            } else {
                cell = dequeueCell(kCitizenshipCellIdentifier, dequeueType, indexPath)
                let doc = sharedPI.citizenshipImmigrationDocument!.docs[indexPath.item]
                (cell as CitizenshipCollectionViewCell).configDoc(doc)
            }
        default:
            assert(false, "Wrong PersonalInformation Type")
        }
        return cell
    }
    
    // MARK: - Others
    func titleForHeaderAtIndexPath(indexPath: NSIndexPath) -> String {
        return sharedPI.categories[indexPath.section]
    }

    func headerViewTapped(headerView: UQCollectionReusableView) {
        let tappedCase: PersonalInformationType = PersonalInformationType(rawValue: sharedPI.categories[headerView.indexPath.section])!
        logInfo("tapped header: \(tappedCase.rawValue)")
        
        mainCollectionVC.showHud(nil)
        Locator.user.getPersonalInformation(tappedCase, success:{ _ in
            JGProgressHUD.dismiss(0, animated: true)
            switch tappedCase {
            case .Addresses:
                logDebug("addresses count: \(self.sharedPI.addresses.count)")
            case .Names:
                logDebug("names count: \(self.sharedPI.names.count)")
            case .PhoneNumbers:
                logDebug("phoneNumbers count: \(self.sharedPI.phoneNumbers.count)")
            case .EmailAddresses:
                logDebug("emails: \(self.sharedPI.emailAddresses != nil)")
            case .EmergencyContacts:
                logDebug("emergency count: \(self.sharedPI.emergencyContacts.count)")
            case .DemographicInformation:
                logDebug("demographic: \(self.sharedPI.demograhicInformation != nil)")
            case .CitizenshipImmigrationDocuments:
                logDebug("citizenshipDoc: \(self.sharedPI.citizenshipImmigrationDocument)")
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