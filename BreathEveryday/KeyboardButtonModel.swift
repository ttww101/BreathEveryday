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
    case add
    case home
    
    var button: UIButton {
        
        guard let button = UINib(nibName: "KeyboardBarButton", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIButton else {
            return UIButton()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        
        switch self {
            
        case .alarm:
            if #available(iOS 11, *) {
                button.setImage(#imageLiteral(resourceName: "Alarm-ios11"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
            } else {
                button.setImage(#imageLiteral(resourceName: "Alarm"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
            }
            
        case .remindTime:
            if #available(iOS 11, *) {
                button.setImage(#imageLiteral(resourceName: "Timer-ios11"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
            } else {
                button.setImage(#imageLiteral(resourceName: "Timer"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
            }
            
        case .calender:
            if #available(iOS 11, *) {
                button.setImage(#imageLiteral(resourceName: "Calendar-ios11"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 33)
            } else {
                button.setImage(#imageLiteral(resourceName: "Calendar"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 33)
            }
            
        case .locate:
            button.setImage(#imageLiteral(resourceName: "Worldwide Location Filled-50"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 27)
            
        case .star:
            if #available(iOS 11, *) {
                button.setImage(#imageLiteral(resourceName: "Star-ios11"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
            } else {
                button.setImage(#imageLiteral(resourceName: "Star"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
            }
            
        case .add:
            if #available(iOS 11, *) {
                button.normalSetup(normalImage: #imageLiteral(resourceName: "Plus-50"),
                                   selectedImage: nil,
                                   tintColor: UIColor.black)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
            } else {
                button.normalSetup(normalImage: #imageLiteral(resourceName: "Plus-50"),
                                       selectedImage: nil,
                                       tintColor: UIColor.black)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
            }
            
        case .home:
            if #available(iOS 11, *) {
                button.normalSetup(normalImage: #imageLiteral(resourceName: "Home-50"),
                                   selectedImage: nil,
                                   tintColor: UIColor.black)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: 0)
            } else {
                button.normalSetup(normalImage: #imageLiteral(resourceName: "Home-50"),
                                   selectedImage: nil,
                                   tintColor: UIColor.black)
                button.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
            }
            
        }

        return button
        
    }
    
}

func adjustFrame(button: UIButton, width: CGFloat, height: CGFloat, image: UIImage?) {
    button.frame = CGRect(x: 0, y: 0, width: width, height: height)
}

let grayBlueColor = UIColor(displayP3Red: 148/255, green: 163/255, blue: 169/255, alpha: 1)


















