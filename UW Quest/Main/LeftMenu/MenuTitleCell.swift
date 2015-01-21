//
//  MenuTitleCell.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-10-26.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class MenuTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    let kAnimationDuration = 0.4
    let titleSelectedColor =  UIColor(white: 1.0, alpha: 0.8)
    let titleNormalColor = UIColor(white: 1.0, alpha: 0.5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            UIView.animateWithDuration(kAnimationDuration, animations: { () -> Void in
                self.titleLabel.textColor = self.titleSelectedColor
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
            })
        } else {
            UIView.animateWithDuration(kAnimationDuration, animations: { () -> Void in
                self.titleLabel.textColor = self.titleNormalColor
                self.backgroundColor = UIColor.clearColor()
            })
        }
    }
}
