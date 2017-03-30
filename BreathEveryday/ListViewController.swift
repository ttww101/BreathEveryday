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

class ListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    @IBAction func homeBtn(_ sender: Any) {
        displayHomeView()
    }
    var tableViewBottomConstraint: NSLayoutConstraint?
    let arrContent: [Content] = []
    var fetchedResultsController: NSFetchedResultsController<Content>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.rowHeight = UITableViewAutomaticDimension
        listTableView.estimatedRowHeight = 77
        listTableView.allowsSelection = false
        listTableView.register(UINib(nibName: Identifier.listCell.rawValue, bundle: nil), forCellReuseIdentifier: Identifier.listCell.rawValue)
        tableViewBottomConstraint = NSLayoutConstraint(item: listTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        //constraints
        view.addConstraint(tableViewBottomConstraint!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //add first Coredata
        AddFirstData()
        
        attemptFetchCoreDataResult()
        
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
    
    
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func attemptFetchCoreDataResult() {
        
        
        let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
        //sort by
        let dateSort = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch {
            
            let error = error as NSError
            print(error)
            
        }
        
    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        listTableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        listTableView.endUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            
            if let indexPath = newIndexPath {
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.listTableView.insertRows(at: [indexPath], with: .fade)
                } , completion: { (_) in
                    
                    //allow new added row to see
                    self.listTableView.scrollToRow(at: indexPath,
                                                   at: .bottom,
                                                   animated: false)
                    
                    //get add cell and ready to type
                    if let addCell = self.listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                        addCell.textView.becomeFirstResponder()
                    }
                    
                })
                
                
            }
            
        case .delete:
            
            if let indexPath = indexPath {
                listTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .update:
            
            if let indexPath = indexPath {
//                let dequeCell = listTableView.cellForRow(at: indexPath) as! ListTableViewCell
//                    dequeCell.configureCell(Content: fetchedResultsController.object(at: indexPath))
                
            }
            
        case .move:
            
            if let indexPath = indexPath {
                listTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                listTableView.insertRows(at: [indexPath], with: .fade)
            }
            
        }
        
    }
    
    //delete coreData
    func requestDeleteData() {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        
        do {
            
            guard let results = try moc.fetch(request) as? [Content] else {
                return
            }
            
            for result in results {
                moc.delete(result)
            }
            
            appDelegate.saveContext()
            
        } catch {
            fatalError("\(error)")
        }
    }
    
    
    func AddFirstData() {
        
        let moc = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        do {
            
            guard let results = try moc.fetch(request) as? [Content] else {
                return
            }
            if results.count == 0 {
                
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "Content", in: moc) else { return }
                print(NSPersistentContainer.defaultDirectoryURL())
                let _ = Content(entity: entityDescription, insertInto: moc)
                
            }
            
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if let sections = fetchedResultsController.sections  {
            
            let sectionInfo = sections[0]
            return sectionInfo.numberOfObjects
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listTableView.dequeueReusableCell(withIdentifier: Identifier.listCell.rawValue, for: indexPath)
        guard let dequeCell = cell as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        dequeCell.viewDetailBtn.addTarget(self, action: #selector(viewChangeToDetailPage), for: .touchUpInside)
        dequeCell.textView.tag = indexPath.row
        if indexPath.row != 0 {
            dequeCell.coveredAddItemView.alpha = 0
        } else {
            dequeCell.coveredAddItemView.alpha = 1
        }
        //sync data
        dequeCell.configureCell(Content: fetchedResultsController.object(at: indexPath))
        return dequeCell
        //        switch indexPath.section {
        //        case listSectionType.content.hashValue:
        //
        //            dequeCell.viewDetailBtn.addTarget(self, action: #selector(viewChangeToDetailPage), for: .touchUpInside)
        //            dequeCell.textView.tag = indexPath.row
        //            dequeCell.coveredAddItemView.alpha = 0
        //            //sync data
        //            dequeCell.configureCell(Content: fetchedResultsController.object(at: indexPath))
        //
        //            return dequeCell
        //
        //        case listSectionType.add.hashValue:
        //
        //            dequeCell.textView.tag = countForEnableCell
        //            dequeCell.coveredAddItemView.alpha = 1
        //
        //            return dequeCell
        //
        //        default:
        //            return cell
        //        }
        
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







