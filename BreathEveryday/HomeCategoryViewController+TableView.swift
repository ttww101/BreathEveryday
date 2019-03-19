//
//  HomeViewController+TableView.swift
//  FeatherList
//
//  Created by Bomi on 2017/9/25.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

extension HomeCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.cellForRow(at: indexPath) == nil {
            guard let cell = settingButtonTableView.dequeueReusableCell(withIdentifier: "SettingButtonTableViewCell", for: indexPath) as? SettingButtonTableViewCell else { return UITableViewCell() }
            switch indexPath.row {
            case 0:
                cell.displayButton.setTitle("Bubbles' Category", for: .normal)
                cell.displayButton.addTarget(self, action: #selector(displayCategorySetup), for: .touchUpInside)
            case 1:
                cell.displayButton.setTitle("Background Image", for: .normal)
                cell.displayButton.addTarget(self, action: #selector(displayBackgroundSetup), for: .touchUpInside)
            case 2:
                cell.displayButton.setTitle("Qoutes", for: .normal)
                cell.displayButton.addTarget(self, action: #selector(displayQuoteSetup), for: .touchUpInside)
            default:
                break
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
}
