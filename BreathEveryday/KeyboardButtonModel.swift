//
//  KeyboardButtonModel.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/12.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

enum CustomButton {
    
    case alarm
    case calender
    case locate
    case star
    
    var button: UIButton {
        
        guard let button = UINib(nibName: "KeyboardBarButton", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIButton else {
            return UIButton()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        
        switch self {
            
        case .alarm:
            
            button.setImage(#imageLiteral(resourceName: "Alarm-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
            
        case .calender:
            
            button.setImage(#imageLiteral(resourceName: "Calendar-64"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 33)
            
        case .locate:
            
            button.setImage(#imageLiteral(resourceName: "Worldwide Location Filled-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 27)
            
        case .star:
            
            button.setImage(#imageLiteral(resourceName: "Star-48"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
            
        }
        
        return button
        
    }
    
}

let grayBlueColor = UIColor(colorLiteralRed: 148/255, green: 163/255, blue: 169/255, alpha: 1)


var heightOfKeyboard: CGFloat = 0

var arrHours: [String] {
    get {
        var arr:[String] = []
        for i in 0...23 {
            let str = String(format: "%02d", i)
            arr.append(str)
        }
        return arr
    }
}

var arrMinutes: [String] {
    get {
        var arr:[String] = []
        for i in 0...59 {
            let str = String(format: "%02d", i)
            arr.append(str)
        }
        return arr
    }
}



