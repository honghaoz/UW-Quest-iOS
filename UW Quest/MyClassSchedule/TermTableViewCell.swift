//
//  TermTableViewCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class TermTableViewCell: UITableViewCell {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
