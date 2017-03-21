//
//  ViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var bubblesBtn: [UIButton] = []
    var bubblesImage: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBubble()
    }
    
    func createBubble() {
        
        let button1 = UIButton()
        let image1 = UIImageView()
        bubblesBtn.append(button1)
        bubblesImage.append(image1)
        
        //button1
        button1.layer.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button1.layer.masksToBounds = true
        button1.layer.cornerRadius = 50
        button1.backgroundColor = UIColor.lightGray
        button1.addTarget(self, action: #selector(displayListView), for: .touchUpInside)
        view.addSubview(button1)

        //image1
        image1.image = #imageLiteral(resourceName: "Shopping Cart-50")
        image1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayListView)))
        image1.layer.frame = CGRect(x: 20, y: 20, width: button1.frame.width - 40, height: button1.frame.height - 40)
        button1.addSubview(image1)

    }
    
    func displayListView() {
        
        if let displayView = storyboard?.instantiateViewController(withIdentifier: Identifier.listView.rawValue) as? UINavigationController {
            
            let subView = UIView()
            subView.layer.frame = displayView.view.frame
            subView.backgroundColor = UIColor.white
            displayView.view.addSubview(subView)
            subView.layer.opacity = 1
            
            self.present(displayView, animated: false, completion: {
                UIView.animate(withDuration: 0.5, animations: {
                    subView.layer.opacity = 0.0
                }, completion: { (_) in
                    subView.removeFromSuperview()
                })
            })
        }

    }
}






