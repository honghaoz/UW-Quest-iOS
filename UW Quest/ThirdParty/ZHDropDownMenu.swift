//
//  ZHDropDownMenu.swift
//  UW Quest
//
//  Created by Honghao Zhang on 1/22/15.
//  Copyright (c) 2015 Honghao. All rights reserved.
//

import UIKit

protocol ZHDropDownMenuDataSource {
    func numberOfItemsInDropDownMenu(menu: ZHDropDownMenu) -> Int
    func zhDropDownMenu(menu: ZHDropDownMenu, itemTitleForIndex index: Int) -> String
}

protocol ZHDropDownMenuDelegate {
    func zhDropDownMenu(menu: ZHDropDownMenu, didSelectIndex index: Int)
}

class ZHDropDownMenu: UIControl {
    var titleLabel: UILabel!
    var color: UIColor = UIColor.blackColor() {
        didSet {
            titleLabel.textColor = color
            indicatorLayer = createTriangleIndicatorWithColor(color, width: kIndicatorWidth)
        }
    }
    
    private var indicatorView: UIView!
    private var indicatorLayer: CAShapeLayer!
    private var contentInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    private let kIndicatorWidth: CGFloat = 8.0
    
    // Data
    var currentTitle: String = " " {
        didSet {
            if currentTitle.length == 0 { currentTitle = " " }
        }
    }
    var kAnimationDuration: NSTimeInterval = 0.25
    var expanded: Bool = false {
        didSet {
            if self.superview == nil {
                return
            }
            let rootSuperView = self.rootView()!
            if expanded {
                addOpaqueOverlayViewForView(rootSuperView)
                // Move table view to the top
                rootSuperView.insertSubview(tableView, belowSubview: self)
                rootSuperView.addConstraints([cTableViewWidth, cTableViewCenterX, cTableViewTop])
                rootSuperView.setNeedsLayout()
                rootSuperView.layoutIfNeeded()
                
                cTableViewTop.constant = self.bounds.height
                let rowsCount: Int = tableView.numberOfRowsInSection(0)
                cTableViewHeight.constant = rowHeight * CGFloat(min(rowsCount, maxExpandingItems))
                UIView.animateWithDuration(kAnimationDuration, animations: { () -> Void in
                    self.tableView.alpha = 1.0
                    // Choose 179.9 to make sure rotation is clockwise
                    self.indicatorView.transform = CGAffineTransformMakeRotation(CGFloat(179.9).radianDegree)
                    rootSuperView.layoutIfNeeded()
                }, completion: { finished -> Void in
                    self.indicatorView.transform = CGAffineTransformMakeRotation(CGFloat(180.0).radianDegree)
                })
            } else {
                // Move table view back to self
                cTableViewTop.constant = 0
                cTableViewHeight.constant = 2.0
                UIView.animateWithDuration(kAnimationDuration, animations: { () -> Void in
                    self.tableView.alpha = 0.0
                    // Choose 0.1 to make sure rotation is counter-clockwise
                    self.indicatorView.transform = CGAffineTransformMakeRotation(CGFloat(0.1).radianDegree)
                    rootSuperView.layoutIfNeeded()
                }, completion: { finished -> Void in
                    self.indicatorView.transform = CGAffineTransformMakeRotation(CGFloat(0).radianDegree)
                    self.tableView.removeFromSuperview()
                    self.removeOpaqueOverlayViewForView(rootSuperView)
                })
            }
        }
    }
    var tableView: UITableView!
    let kCellIdentifier = "CellIndentifier"
    
    var maxExpandingItems: Int = 4
    
    // tableView.top <=> self.top
    var cTableViewTop: NSLayoutConstraint!
    var cTableViewCenterX: NSLayoutConstraint!
    var cTableViewWidth: NSLayoutConstraint!
    var cTableViewHeight: NSLayoutConstraint!
    
    var dataSource: ZHDropDownMenuDataSource?
    var delegate: ZHDropDownMenuDelegate?
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupViews()
        setupActions()
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.clearColor()
        
        // TitleLabel
        titleLabel = UILabel()
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(titleLabel)
        // Triangle Indicator
        indicatorView = UIView()
        indicatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(indicatorView)
        
        let top = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: contentInset.top)
        let left = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: contentInset.left)
        let bottom = NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -contentInset.bottom)
        let right = NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: indicatorView, attribute: .Left, multiplier: 1.0, constant: -contentInset.right)
        self.addConstraints([top, left, bottom, right])
        
        let width = NSLayoutConstraint(item: indicatorView, attribute: .Width, relatedBy: .Equal, toItem: indicatorView, attribute: .Width, multiplier: 0, constant: kIndicatorWidth)
        let height = NSLayoutConstraint(item: indicatorView, attribute: .Height, relatedBy: .Equal, toItem: indicatorView, attribute: .Height, multiplier: 0, constant: (ceil(sin((60.0 as CGFloat).radianDegree) as CGFloat) as CGFloat) * kIndicatorWidth)
        indicatorView.addConstraints([width, height])
        
        let verticalCenter = NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: indicatorView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let indicatorViewRight = NSLayoutConstraint(item: indicatorView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -contentInset.right)
        self.addConstraints([verticalCenter, indicatorViewRight])
        
        titleLabel.setContentHuggingPriority(250, forAxis: .Horizontal)
        titleLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        titleLabel.textAlignment = .Right
        titleLabel.font = UIFont.helveticaNenueFont(15)
        
        titleLabel.text = currentTitle
        
        // Triangle Indicator
        indicatorLayer = createTriangleIndicatorWithColor(color, width: kIndicatorWidth)
        indicatorView.layer.addSublayer(indicatorLayer)
        
        setupTableView()
    }
    
    private func setupActions() {
        self.addTarget(self, action: "tapped:forEvent:", forControlEvents: .TouchUpInside)
    }
    
    func tapped(sender: AnyObject, forEvent event: UIEvent) {
        expanded = !expanded
    }
}

// MARK: TableView
extension ZHDropDownMenu: UITableViewDataSource, UITableViewDelegate {
    var rowHeight: CGFloat { return self.titleLabel.bounds.height + 10 }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Setup constraints, but won't add to view, will add it when expanding
        cTableViewHeight = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: tableView, attribute: .Height, multiplier: 0.0, constant: 2.0)
        tableView.addConstraint(cTableViewHeight)
        
        cTableViewWidth = NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        cTableViewCenterX = NSLayoutConstraint(item: tableView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        cTableViewTop = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        tableView.alpha = 0.0
        
        tableView.separatorStyle = .None
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource != nil {
            return dataSource!.numberOfItemsInDropDownMenu(self)
        } else {
            return 5
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as AnyObject! as UITableViewCell
        cell.textLabel?.text = "1234567"
        return cell
    }
    
    // Delegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.zhDropDownMenu(self, didSelectIndex: indexPath.row)
    }
}

// MARK: Helper
extension ZHDropDownMenu {
    func createTriangleIndicatorWithColor(color: UIColor, width: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.contentsScale = UIScreen.mainScreen().scale
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(width, 0))
        path.addLineToPoint(CGPointMake(width / 2.0, (sin((60.0 as CGFloat).radianDegree) as CGFloat) * width))
        path.closePath()
        
        layer.path = path.CGPath
        layer.lineWidth = 1.0
        layer.fillColor = color.CGColor
        
        return layer
    }
    
    /**
    Find the root parent view
    
    :returns: root parent view
    */
    func rootView() -> UIView? {
        if self.superview == nil {
            return nil
        }
        var currentSuperView = self.superview!
        while currentSuperView.superview != nil {
            currentSuperView = currentSuperView.superview!
        }
        return currentSuperView
    }
    
    /// This number is used for tagging overlay view
    var magicTagNumber: Int { return 9999 }
    
    func addOpaqueOverlayViewForView(view: UIView) {
        let overlayView = UIView()
        overlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        overlayView.tag = magicTagNumber
        view.addSubview(overlayView)
        
        let top = NSLayoutConstraint(item: overlayView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: overlayView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: overlayView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: overlayView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0)
        view.addConstraints([top, left, bottom, right])
        
        let touchSelector = Selector("rootViewIsTouched:")
        let tapGesture = UITapGestureRecognizer(target: self, action: touchSelector)
        let panGesture = UIPanGestureRecognizer(target: self, action: touchSelector)
        overlayView.addGestureRecognizer(tapGesture)
        overlayView.addGestureRecognizer(panGesture)
    }
    
    func removeOpaqueOverlayViewForView(view: UIView) {
        let overlayView: UIView? = view.viewWithTag(magicTagNumber)
        overlayView?.removeFromSuperview()
    }
    
    func rootViewIsTouched(gesture: UIGestureRecognizer) {
        expanded = false
    }
}
