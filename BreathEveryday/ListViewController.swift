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
import EventKit

class ListViewController: UIViewController {
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var listTableView: UITableView!
    
    @IBAction func homeBtn(_ sender: Any) {
        
        displayHomeView()
        
//        EventManager.shared.deleteAll()
        //note: after saveContext the ID will totoally different
        EventManager.shared.appDelegate.saveContext()
    }
    
    @IBAction func addEventBtn(_ sender: Any) {
        
        EventManager.shared.create(calendarEvent: nil, content: nil, detail: nil)
        
        EventManager.shared.appDelegate.saveContext()
    }
    
    var tableViewBottomConstraint: NSLayoutConstraint?
    var fetchedResultsController: NSFetchedResultsController<EventMO>!
    var isTyping = false
    
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
        //swipe
        let leftSwipe = UIPanGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
//        view.addGestureRecognizer(leftSwipe)
        
        //constraints
        view.addConstraint(tableViewBottomConstraint!)
        
        //notification
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
        case .authorized: print("Access agreeed")
        case .denied: print("Access denied")
        case .notDetermined:
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if granted { print("granted")
                } else { print("Access denied")  }
            })
            
        default: print("Case Default")
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
    
    //Gesture
    func handleTapGesture(recognizer: UIGestureRecognizer) {
        
    }
    
    
    func handleLeftSwipe(recognizer: UIPanGestureRecognizer) {
        
        let vel = recognizer.velocity(in: self.listTableView)
        if vel.x < 0 {
            
            switch recognizer.state {
                
            case .began:
                break
                
            case .ended:
                if isTyping == false && recognizer.location(in: self.listTableView).x < 44  {
                    let location = recognizer.location(in: self.listTableView)
                    
                    if let indexPath = listTableView.indexPathForRow(at: location) {
                        
                        //TODO: collection of O2
                        
                    }

                    //animation : reveal delete mark
                }
            default:
                break
                
            }
            
        } else if vel.x > 0 {
            //animation : disappear delete mark
            if recognizer.location(in: self.listTableView).x == 44 {
                print("44 right")
            }
            
        }
        
    }
    
    //Notification Center
    func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            if let rectInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                
                //get rect
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                tableViewBottomConstraint?.constant = isKeyboardShowing ? -rectInfo.height : 0
                heightOfKeyboard = isKeyboardShowing ? rectInfo.height : 0
                
                isTyping = isKeyboardShowing ? true : false
                
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
    
}

// CoreData
extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func fetchCoreDataResult() {
        
        let fetchRequest: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        //sort by
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
            
            if let indexPath = newIndexPath {
                
                UIView.animate(withDuration: 0, animations: {
                    
                    self.listTableView.insertRows(at: [indexPath], with: .fade)
                    
                } , completion: { (_) in
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        self.listTableView.scrollToRow(at: indexPath,
                                                       at: .bottom,
                                                       animated: false)
                        
                        
                    }, completion: { (_) in
                        // ?? can't work
                        if let addCell = self.listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                            addCell.textView.becomeFirstResponder()
                        }
                        
                    })
                    
                })
                
                
            }
            
        case .delete:
            
            if let indexPath = indexPath {
                listTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .update:
            
            if let indexPath = indexPath {
                listTableView.reloadRows(at: [indexPath], with: .fade)
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
        
    
}

// TableView
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if !isTyping {
            if editingStyle == UITableViewCellEditingStyle.delete {
                
                guard let objectID = fetchedResultsController.fetchedObjects?[indexPath.row].objectID else { return }
                
                EventManager.shared.delete(id: objectID)
                
                print("1")
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
        
        dequeCell.configureCell(event: fetchedResultsController.object(at: indexPath))
        
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







