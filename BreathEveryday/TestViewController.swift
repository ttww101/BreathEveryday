//
//  TestViewController.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/10/21.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellEmergeOrderly(from: 0)
//        tableView.rotate(times: 5)
    }
    
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.orange
        
        return cell
    }
    
}
