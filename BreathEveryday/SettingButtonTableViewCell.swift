//
//  SettingButtonTableViewCell.swift
//  BreathEveryday
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
