//
//  ListViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//
enum listSectionType {
    case add
    case content
}


import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var listTableView: UITableView!
    @IBAction func homeBtn(_ sender: Any) {
        displayHomeView()
    }
    var tableViewBottomConstraint: NSLayoutConstraint?
    let moc = UIApplication.shared.delegate as! AppDelegate
    let arrContent: [Content] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.rowHeight = UITableViewAutomaticDimension
        listTableView.estimatedRowHeight = 77
        listTableView.allowsSelection = false
        listTableView.register(UINib(nibName: Identifier.listCell.rawValue, bundle: nil), forCellReuseIdentifier: Identifier.listCell.rawValue)
        tableViewBottomConstraint = NSLayoutConstraint(item: listTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(tableViewBottomConstraint!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Coredata
        requestDeleteData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestGetData()
        
    }
    
    
    //delete coreData
    func requestDeleteData() {
        
        let managedContext = moc.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        
        do {
            
            guard let results = try managedContext.fetch(request) as? [Content] else {
                return
            }
            
            for result in results {
                managedContext.delete(result)
            }
            
            moc.saveContext()
            
        } catch {
            fatalError("\(error)")
        }
    }
    
    
    //get content
    func requestGetData() {
        
        let managedContext = moc.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        do {
            guard let results = try managedContext.fetch(request) as? [Content] else {
                return
            }
            
            results.forEach({ (result) in
                
                print(result)
                
            })
            
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
    }
    
    
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let rectInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                //get rect
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                tableViewBottomConstraint?.constant = isKeyboardShowing ? -rectInfo.height : 0
                
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: { 
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.35, animations: {
                        
                        if let firstCell = self.listTableView.cellForRow(at: IndexPath(row: 1, section: listSectionType.add.hashValue)) as? ListTableViewCell {
                            firstCell.contentView.frame = CGRect(x: firstCell.contentView.frame.minX , y: firstCell.contentView.frame.minY, width: firstCell.contentView.frame.width, height: firstCell.contentView.frame.height)
                        }
                        
                    })
                })
                
            }
        }
    }


    //Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Appearance of Back btn
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    func viewChangeToDetailPage(sender: UIButton) {
        
        guard let cell = sender.superview?.superview?.superview as? ListTableViewCell else { return }
        performSegue(withIdentifier: Identifier.detailView.rawValue, sender: cell)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //end editing
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case listSectionType.content.hashValue:
            return countForEnableCell
        case listSectionType.add.hashValue:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listTableView.dequeueReusableCell(withIdentifier: Identifier.listCell.rawValue, for: indexPath)
        guard let dequeCell = cell as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case listSectionType.content.hashValue:
            
            dequeCell.viewDetailBtn.addTarget(self, action: #selector(viewChangeToDetailPage), for: .touchUpInside)
            dequeCell.textView.tag = indexPath.row
            dequeCell.coveredAddItemView.alpha = 0

            return dequeCell
            
        case listSectionType.add.hashValue:
            
            dequeCell.textView.tag = countForEnableCell
            dequeCell.coveredAddItemView.alpha = 1
            
            return dequeCell
            
        default:
            return cell
        }
        
    }
    
    func displayHomeView() {
        
        if let displayView = storyboard?.instantiateViewController(withIdentifier: Identifier.homeView.rawValue) as? HomeViewController {
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







