//
//  TableLayout.swift
//  PageFlowLayout
//
//  Created by Honghao Zhang on 3/1/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

@objc protocol TableLayoutDataSource {
    func numberOfColumnsInCollectionView(collectionView: UICollectionView) -> Int
    func collectionView(collectionView: UICollectionView, numberOfRowsInColumn column: Int) -> Int
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, titleForColumn column: Int) -> String
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: TableCollectionViewLayout, contentForColumn column: Int, row: Int) -> String
}

class TableCollectionViewLayout: UICollectionViewLayout {
    // NSIndexPath.item == 0, for title cells
    // NSIndexPath.item >  0, for content cells
    // However, for TableLayoutDataSource, column and row start from zero
    
    // SeparatorLine is decorationViews
    
    var titleFont: UIFont = UIFont(name: "HelveticaNeue", size: 17)!
    var contentFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 17)!
    
    var horizontalPadding: CGFloat = 5.0
    var verticalPadding: CGFloat = 1.0
    var separatorLineWidth: CGFloat = 1.0
    var separatorColor: UIColor = UIColor(white: 0.0, alpha: 0.5)
//        {
//        didSet {
//            TableCollectionViewSeparatorView.separatorColor = separatorColor
//        }
//    }
    
    var titleLabelHeight: CGFloat { return "ABC".zhExactSize(titleFont).height }
    var contentLabelHeight: CGFloat { return "ABC".zhExactSize(contentFont).height }
    
    var dataSource: UICollectionViewDataSource {
        return self.collectionView!.dataSource!
    }
    var dataSourceTableLayout: TableLayoutDataSource {
        return (self.collectionView! as! TableCollectionView).tableLayoutDataSource
    }
    
    var sections: Int {
        return dataSource.numberOfSectionsInCollectionView!(collectionView!)
    }
    
    var maxWidthsForSections = [CGFloat]()
    var maxContentHeight: CGFloat = 0
    
    var kSeparatorViewKind = "Separator"
    override init() {
        super.init()
        self.registerClass(TableCollectionViewSeparatorView.self, forDecorationViewOfKind: kSeparatorViewKind)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareLayout() {
        buildMaxWidthsHeight()
    }
    
    func buildMaxWidthsHeight() {
        // Calculate MaxWidths
        maxWidthsForSections.removeAll(keepCapacity: false)
        for col in 0 ..< sections {
            let title = dataSourceTableLayout.collectionView(collectionView!, layout: self, titleForColumn: col)
            var maxWidth = title.zhExactSize(titleFont).width
            let items = dataSource.collectionView(collectionView!, numberOfItemsInSection: col)
            for row in 1 ..< items {
                // row: row - 1, to let row start from 0
                let content = dataSourceTableLayout.collectionView(collectionView!, layout: self, contentForColumn: col, row: row - 1)
                var contentWidth = content.zhExactSize(contentFont).width
                if contentWidth > maxWidth {
                    maxWidth = contentWidth
                }
            }
            maxWidthsForSections.append(maxWidth)
        }
        
        // Calculate Max Height
        var maxItemsCount = 0
        for i in 0 ..< sections {
            let itemsCount = dataSource.collectionView(collectionView!, numberOfItemsInSection: i)
            if maxItemsCount < itemsCount {
                maxItemsCount = itemsCount
            }
        }
        
        maxContentHeight = titleLabelHeight + verticalPadding * 2 + separatorLineWidth + CGFloat(maxItemsCount - 1) * (contentLabelHeight + verticalPadding * 2)
    }
    
    override func collectionViewContentSize() -> CGSize {
        var width: CGFloat = maxWidthsForSections.reduce(0, combine: +)
        width += CGFloat(sections - 1) * separatorLineWidth
        width += CGFloat(sections) * horizontalPadding * 2
        return CGSizeMake(width, maxContentHeight)
    }
        
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        var x: CGFloat = 0
        for sec in 0 ..< indexPath.section {
            x += maxWidthsForSections[sec] + separatorLineWidth + horizontalPadding * 2
        }
        var y: CGFloat = 0
        let width: CGFloat = maxWidthsForSections[indexPath.section] + horizontalPadding * 2
        var height =  dataSourceTableLayout.collectionView(collectionView!, layout: self, titleForColumn: indexPath.section).zhExactSize(titleFont).height + verticalPadding * 2
        
        if indexPath.item > 0 {
            y = dataSourceTableLayout.collectionView(collectionView!, layout: self, titleForColumn: indexPath.section).zhExactSize(titleFont).height + verticalPadding * 2 + separatorLineWidth
            for item in 1 ..< indexPath.item {
                y += dataSourceTableLayout.collectionView(collectionView!, layout: self, contentForColumn: indexPath.section, row: item).zhExactSize(contentFont).height + verticalPadding * 2.0
            }
            
            // row: indexPath.item - 1, to let row start from 0
            height = dataSourceTableLayout.collectionView(collectionView!, layout: self, contentForColumn: indexPath.section, row: indexPath.item - 1).zhExactSize(contentFont).height + verticalPadding * 2
        }
        
        attrs.frame = CGRectMake(x, y, width, height)
        
        return attrs
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attrs = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, withIndexPath: indexPath)
        attrs.hidden = true
        if elementKind == kSeparatorViewKind {
            if indexPath.item == 0 {
                attrs.hidden = false
                if indexPath.section == 0 {
                    var x: CGFloat = 0
                    var y = titleLabelHeight + verticalPadding * 2
                    var width = self.collectionViewContentSize().width
                    attrs.frame = CGRectMake(x, y, width, separatorLineWidth)
                } else {
                    var x: CGFloat = 0
                    for sec in 0 ..< indexPath.section {
                        x += maxWidthsForSections[sec] + separatorLineWidth + horizontalPadding * 2
                    }
                    x -= separatorLineWidth
                    var y: CGFloat = 0.0
                    var width = separatorLineWidth
                    var height = self.collectionViewContentSize().height
                    attrs.frame = CGRectMake(x, y, width, height)
                }
            }
        }
        return attrs
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attrs = [UICollectionViewLayoutAttributes]()
        let section: Int = collectionView!.dataSource!.numberOfSectionsInCollectionView!(collectionView!)
        for sec in 0 ..< section {
            for row in 0 ..< collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: sec) {
                attrs.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: row, inSection: sec)))
                attrs.append(self.layoutAttributesForDecorationViewOfKind(kSeparatorViewKind, atIndexPath: NSIndexPath(forItem: row, inSection: sec)))
            }
        }
        return attrs
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}

extension String {
    func zhExactSize(font: UIFont) -> CGSize {
        var newSize = self.sizeWithAttributes([NSFontAttributeName: font])
        if self.isEmpty {
            newSize = " ".sizeWithAttributes([NSFontAttributeName: font])
        }
        newSize.width = ceil(newSize.width)
        newSize.height = ceil(newSize.height)
        return newSize
    }
}