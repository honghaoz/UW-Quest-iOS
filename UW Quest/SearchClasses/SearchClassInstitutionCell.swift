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
        
        institutionMenu.textColor = UQLabelFontColor
        institutionMenu.titleFont = UIFont.helveticaNeueLightFont(17)
        termMenu.textColor = UQLabelFontColor
        termMenu.titleFont = UIFont.helveticaNeueLightFont(17)
        
        setup()
    }
    
    private func setup() {
        institutionMenu.dataSource = self
        institutionMenu.delegate = self
        institutionMenu.currentSelectedIndex = 1
        
        termMenu.dataSource = self
        termMenu.delegate = self
    }
}

extension SearchClassInstitutionCell: ZHDropDownMenuDataSource, ZHDropDownMenuDelegate {
    func numberOfItemsInDropDownMenu(menu: ZHDropDownMenu) -> Int {
        return 6
    }
    
    func zhDropDownMenu(menu: ZHDropDownMenu, itemTitleForIndex index: Int) -> String {
        switch index {
        case 0:
            return "abcd"
        case 1:
            return "hahah this "
        case 2:
            return "great man"
        case 3:
            return "awesome!"
        case 4:
            return "cool guys"
        default:
            return "this is amazing!"
        }
    }
    
    func zhDropDownMenu(menu: ZHDropDownMenu, didSelectIndex index: Int) {
        logDebug("didSelected: \(index)")
    }
}