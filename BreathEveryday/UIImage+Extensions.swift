//
//  UIImage+Extensions.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/11/9.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
