//
//  UQButton.swift
//  UW Quest
//
//  Created by Honghao on 9/13/14.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import UIKit

class UQButton: UIButton {
    
//    override var backgroundColor: UIColor? {
//        get {
//            return self.backgroundColor
//        }
//        set {
//            println("called")
//            super.backgroundColor = newValue
////            if let realBackgroundColor:UIColor = newValue {
////                self.setBackgroundColor(realBackgroundColor, forState: UIControlState.Normal)
////                let dimmedBackground: UIColor = realBackgroundColor.colorWithAlphaComponent(realBackgroundColor.getAlphaComponent() - 0.3)
////                self.setBackgroundColor(realBackgroundColor, forState: UIControlState.Highlighted)
////            }
//        }
//    }
    
    func setBackgroundColor(backgroundColor: UIColor?, forState state: UIControlState) {
        var colorView: UIView = UIView(frame: self.frame)
        colorView.backgroundColor = backgroundColor
        UIGraphicsBeginImageContext(colorView.bounds.size)
        colorView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let colorImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, forState: state)
    }
    
    // MARK: helper
    
//    func image(color: UIColor?, cornerRadius radius: CGFloat) -> UIImage {
//        var red: CGFloat = 0.0
//        var green: CGFloat = 0.0
//        var blue: CGFloat = 0.0
//        var aplha: CGFloat = 0.0
//        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
//        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
//        CGContextSetRGBFillColor(ctx, red, green, blue, aplha)
//        
//        var roundedRect: CGRect = self.bounds
//        CGContextfil
//    }
}
