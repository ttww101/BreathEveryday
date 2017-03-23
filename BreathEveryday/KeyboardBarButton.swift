//
//  KeyboardBarButtonView.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/22.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class KeyboardBarButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView?.contentMode = .scaleAspectFit
    }
    
}
