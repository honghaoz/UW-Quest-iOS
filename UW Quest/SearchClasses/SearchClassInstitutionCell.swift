//
//  SearchClassInstitutionCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/21/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class SearchClassInstitutionCell: UITableViewCell {

    @IBOutlet weak var institutionMenu: ZHDropDownMenu!
    @IBOutlet weak var termMenu: ZHDropDownMenu!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
    }
}