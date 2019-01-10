//
//  HomeItemView.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/5/5.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class QuoteView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.black.lighter(amount: 0.5).cgColor
        self.backgroundColor = UIColor.white.lighter(amount: 0.1)
        self.layer.borderWidth = 2
    }
    
}

class QuoteLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.numberOfLines = 0
        self.font = UIFont(name: "Menlo", size: 16)
        self.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


class CategoryDoneButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.normalSetup(normalImage: #imageLiteral(resourceName: "Checkmark Filled-50"),
                         selectedImage: nil,
                         tintColor: UIColor.greenAirwaves())
        self.setTitleColor(UIColor.greenAirwaves(), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
    
}

import IGColorPicker
class IGColorPickerView: ColorPickerView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.darkPurple()
        self.colors = UIColor.arrayOfCategoriesSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


