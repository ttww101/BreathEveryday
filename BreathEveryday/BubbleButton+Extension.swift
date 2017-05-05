//
//  BubbleButton+Extension.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/5/5.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import DynamicColor

extension UIButton {
    
    func setBubbleColor(with color: UIColor) {
        //color
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        let dynamicGradient = DynamicGradient(colors: [UIColor.white, color, color.darkened()])
        gradientLayer.colors = [dynamicGradient.pickColorAt(scale: 0).cgColor, color.cgColor, dynamicGradient.pickColorAt(scale: 0.6).cgColor]
        self.layer.insertSublayer(gradientLayer, below: self.imageView?.layer)
        self.layer.opacity = 0.6
        
        //shadow
        self.layer.shadowColor = self.backgroundColor?.shaded().cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = false
    }
    
}
