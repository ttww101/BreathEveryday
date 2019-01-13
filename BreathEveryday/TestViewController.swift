//
//  TestViewController.swift
//  BreathEveryday
//
//  Created by Bomi on 2017/10/21.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM

class TestViewController: UIViewController {

    @IBOutlet var tableView:UITableView!
    var quotes: [LCQuote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.cellEmergeOrderly(from: 0)
//        tableView.rotate(times: 5)
        self.grabQuotes()
    }
    
    func grabQuotes() {
        
        let query: AVQuery = AVQuery(className: "LCQuote")
        query.findObjectsInBackground { (objects, error) in
            if error != nil { return }
            
            guard let objects = objects as? Array<AVObject> else { return }
            
            for object in objects {
                let dic = object.dictionaryForObject()
                
                if let id = dic[LCQuote.idKey] as? String, let text = dic[LCQuote.textKey] as? String {
                    let quote = LCQuote(id: id, text: text)
                    self.quotes.append(quote)
                }
            }
            
            self.tableView.reloadData()
        }
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//            for (NSDictionary *object in objects) {
//            LCEvent *event = [LCEvent initWithObject:object];
//            [self.adArr addObject:event];
//            }
//
//            if ([self.adArr count] > 0) {
//            NSString *url = [self.adArr firstObject].website;
//
//            NSURL *check = [NSURL URLWithString:url];
//
//            if (check == nil) {
//            [self performSegueWithIdentifier:@"sgMain" sender:nil];
//            }
//            else {
//            ADWKWebViewController *VC = [ADWKWebViewController initWithURL:url];
//            [[[[UIApplication sharedApplication]delegate]window]setRootViewController:VC];
//            }
//            }
//            else {
//            [self performSegueWithIdentifier:@"sgMain" sender:nil];
//            }
//            }
//            }];
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            
            let initCell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            
            initCell.backgroundColor = UIColor.orange
            initCell.textLabel?.text = self.quotes[indexPath.row].text
            
            return initCell
        }
        
        cell.backgroundColor = UIColor.orange
        cell.detailTextLabel?.text = self.quotes[indexPath.row].text
        
        return cell
    }
    
}
