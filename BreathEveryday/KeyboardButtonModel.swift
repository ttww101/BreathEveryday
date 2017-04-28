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
    case remindTime
    
    var button: UIButton {
        
        guard let button = UINib(nibName: "KeyboardBarButton", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIButton else {
            return UIButton()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        
        switch self {
            
        case .alarm:
            
            button.setImage(#imageLiteral(resourceName: "Alarm-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
            
        case .remindTime:
            
            button.setImage(#imageLiteral(resourceName: "Timer-48"), for: .normal)
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

func adjustFrame(button: UIButton, width: CGFloat, height: CGFloat, image: UIImage?) {
    button.frame = CGRect(x: 0, y: 0, width: width, height: height)
}

let grayBlueColor = UIColor(colorLiteralRed: 148/255, green: 163/255, blue: 169/255, alpha: 1)


















