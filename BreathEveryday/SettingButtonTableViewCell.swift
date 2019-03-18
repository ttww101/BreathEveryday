//
//  SettingButtonTableViewCell.swift
//  FeatherList
//
//  Created by Bomi on 2017/9/25.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class SettingButtonTableViewCell: UITableViewCell {

    @IBOutlet var displayButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.displayButton.layer.borderColor = UIColor.white.cgColor
        self.displayButton.layer.borderWidth = 2
        self.displayButton.layer.masksToBounds = true
        self.displayButton.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
