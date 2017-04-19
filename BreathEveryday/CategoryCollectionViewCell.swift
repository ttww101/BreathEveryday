//
//  CategoryCollectionViewCell.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/17.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
//    var colorBK: UIColor = .lightGray
    var isCreated: Bool = false
    var numberOfArr: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        if self.isSelected {
            self.contentView.layer.opacity = 1
        } else {
            self.contentView.layer.opacity = 0.3
        }
    }

    override var isSelected: Bool {
        didSet {
//            self.contentView.backgroundColor = isSelected ? colorBK : colorDarkPurple
            self.contentView.layer.opacity = isSelected ? 1 : 0.3
            self.imageView.alpha = isSelected ? 1 : 1.0
        }
    }

}



