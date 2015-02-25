//
//  MyClassScheduleTermViewController.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2/24/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

class MyClassScheduleTermViewController: UIViewController {

    @IBOutlet weak var headerTermLabel: UILabel!
    @IBOutlet weak var headerLevelLabel: UILabel!
    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var headerInformationLabel: ZHAutoLinesLabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.title = "Spring 2014"
    }
    
    private func setupView() {
        self.view.backgroundColor = UQBackgroundColor
    }
}
