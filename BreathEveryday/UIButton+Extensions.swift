//
//  ExtensionButtonModel.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/5/5.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension UIButton {
    
    func normalSetup(normalImage: UIImage, selectedImage: UIImage?, tintColor: UIColor) {
        
        self.tintColor = tintColor
        var setupImage = normalImage.withRenderingMode(.alwaysTemplate)
        self.setImage(setupImage, for: .normal)
        if let image = selectedImage {
            setupImage = image.withRenderingMode(.alwaysTemplate)
            self.setImage(setupImage, for: .selected)
        }
        self.imageView?.contentMode = .scaleAspectFit
        
    }
    
    func setFrameToCircle() {
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
        
    }
    
}
