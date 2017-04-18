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
    var isCreated: Bool = false
    var numberOfArr: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
