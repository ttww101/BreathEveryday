//
//  ListViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class ListViewController: UIViewController {
    
    let eventStore = EKEventStore()
    @IBOutlet weak var listTableView: UITableView!
    var tableViewBottomConstraint: NSLayoutConstraint?
    var fetchedResultsController: NSFetchedResultsController<EventMO>!
    var isTyping = false
    var listTitle = ""
    var bubbleSyncColor: UIColor = .white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sync to bubble
        self.navigationController?.navigationBar.barTintColor = bubbleSyncColor
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.topItem?.title = listTitle
        let homeBtn = CustomButton.home.button
        homeBtn.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeBtn)

        let addEventBtn = CustomButton.add.button
        addEventBtn.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addEventBtn)
        listTableView.backgroundColor = bubbleSyncColor
        
        //tableView
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.rowHeight = UITableViewAutomaticDimension
        listTableView.estimatedRowHeight = 77
        listTableView.allowsSelection = false
        listTableView.register(UINib(nibName: Identifier.listCell.rawValue, bundle: nil), forCellReuseIdentifier: Identifier.listCell.rawValue)
        
        //notification for constraints
        tableViewBottomConstraint = NSLayoutConstraint(item: listTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(tableViewBottomConstraint!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //fetchDataResult
        fetchCoreDataResult()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        askCalendarAuthorized()
    }
    
    func askCalendarAuthorized() {
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized: break
        case .denied: break
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if granted { print("granted")
                } else { print("Access denied")  }
            })
            
        default: print("Case Default")
        }
    }
    
    @objc func backHome(_ sender: Any) {
        displayHomeView()
        //note: after saveContext the ID will totoally different
        EventManager.shared.appDelegate.saveContext()
    }
    
    @objc func addEvent(_ sender: Any) {
        EventManager.shared.create(calendarEvent: nil, content: nil, note: nil, category: listTitle)
        EventManager.shared.appDelegate.saveContext()
    }
    
    @objc func viewChangeToDetailPage(sender: UIButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            
            UIView.animate(withDuration: 1, animations: {
                //nav
                let backItem = UIBarButtonItem()
                viewController.navigationController?.navigationBar.tintColor = UIColor.black
                self.navigationItem.backBarButtonItem = backItem
                
                //attributes
                viewController.bubbleSyncColor = self.bubbleSyncColor
                if let event = EventManager.shared.read(row: sender.tag) {
                    viewController.entryRow = sender.tag
                    if let noteData = event.note {
                        viewController.noteData = noteData
                    }
                }
            }, completion: { (_) in
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            })

        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let rectInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                
                //get rect
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                
                tableViewBottomConstraint?.constant = isKeyboardShowing ? -rectInfo.height : 0
                
                isTyping = isKeyboardShowing ? true : false
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0, animations: {
                                                
                    })
                })
                
            }
        }
    }
    
}

// CoreData
extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func fetchCoreDataResult() {
        
        let fetchRequest: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        //sort by
        EventManager.shared.request.predicate = NSPredicate(format: "category == %@", listTitle)
        fetchRequest.predicate = NSPredicate(format: "category == %@", listTitle)
        let dateSort = NSSortDescriptor(key: "createdDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: EventManager.shared.appDelegate.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch {
            
            //TODO: Err
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
            
            
            if let newIndexPath = newIndexPath {
                
                UIView.animate(withDuration: 0, animations: {
                    
                    self.listTableView.insertRows(at: [newIndexPath], with: .fade)
                    
                } , completion: { (_) in
                    
                        UIView.animate(withDuration: 0.1, animations: {
                            
                            self.listTableView.scrollToRow(at: newIndexPath,
                                                           at: .none,
                                                           animated: false)
                            
                        }, completion: { (_) in
                            
                            
                            if let addCell = self.listTableView.cellForRow(at: newIndexPath) as? ListTableViewCell {
                                addCell.textView.becomeFirstResponder()
                                
                                //ensure visible, or it cannot work when adding 7~12
                                self.listTableView.scrollToRow(at: newIndexPath,
                                                               at: .none,
                                                               animated: false)
                            }
                            
                        })
                    
                    
                })
                
                
            }
            
        case .delete:
            
            if let indexPath = indexPath {
                
                listTableView.deleteRows(at: [indexPath], with: .fade)
                
                //reload indexRow in cell for save data 
                if let cellCount = fetchedResultsController.fetchedObjects?.count {
                    for i in indexPath.row...cellCount {
                        if let cell = listTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ListTableViewCell {
                            cell.indexRow = i - 1
                        }
                    }
                }
            }
            
        case .update:
            
            if let indexPath = indexPath {
                listTableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        case .move:
            
            if let indexPath = indexPath, let newIndexPath =  newIndexPath{
                listTableView.moveRow(at: indexPath, to: newIndexPath)
            }
            
        }
        
    }
        
    
}

// TableView
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.detailBtnLeadingConstraint?.constant = 200
            cell.contentView.layoutIfNeeded()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        guard let indexPath = indexPath else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.detailBtnLeadingConstraint?.constant = cell.numDetailImageToTextView
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if isTyping {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if !isTyping {
            if editingStyle == UITableViewCellEditingStyle.delete {
                
                guard let objectID = fetchedResultsController.fetchedObjects?[indexPath.row].objectID else { return }
                
                EventManager.shared.delete(id: objectID)
                if let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
                    cell.detailBtnLeadingConstraint?.constant = view.frame.width + 100
                    cell.contentView.layoutIfNeeded()
                }
            }
        }
        
    }
    
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
        
        dequeCell.indexRow = indexPath.row
        
        dequeCell.viewDetailBtn.tag = indexPath.row
        
        dequeCell.configureCell(event: fetchedResultsController.object(at: indexPath))
        
        dequeCell.calendarPopupViewDelegate = self
        
        dequeCell.backgroundColor = bubbleSyncColor
        
        return dequeCell
        
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


extension ListViewController: calendarPopupViewProtocol {
    
    func addViewControllerAsChild(viewController: CalendarViewController) {
        self.addChildViewController(viewController)
    }
}













