//
//  ZHExtendView.swift
//  DogSync
//
//  Created by Honghao on 12/20/14.
//  Copyright (c) 2014 Adam Dahan. All rights reserved.
//

import UIKit

@IBDesignable
class ZHExtendView: UIView {
    @IBInspectable
    var borderColor: UIColor = UIColor.clearColor() {
        didSet { layer.borderColor = borderColor.CGColor }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
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
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        if isRounded {
            let width = fmin(CGRectGetWidth(bounds), CGRectGetHeight(bounds))
            layer.cornerRadius = width / 2.0
        }
    }

//    override func prepareForInterfaceBuilder() {
//        
//    }
}

@IBDesignable
class ZHExtendImageView: UIImageView {
    @IBInspectable
    var borderColor: UIColor = UIColor.clearColor() {
        didSet { layer.borderColor = borderColor.CGColor }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
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
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        if isRounded {
            layer.cornerRadius = CGRectGetWidth(bounds) / 2.0
        }
    }
}
