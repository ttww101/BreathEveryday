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
import SpriteKit

class ListViewController: UIViewController {
    
    let eventStore = EKEventStore()
    @IBOutlet weak var listTableView: UITableView!
    weak var backgroundImageView: UIImageView!
    @IBOutlet weak var completedListButton: UIButton!
    var addEventButton: UIButton!
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
        self.navigationItem.title = listTitle
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        let homeBtn = CustomButton.home.button
        homeBtn.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeBtn)
        addEventButton = CustomButton.add.button
        addEventButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addEventButton)
        listTableView.backgroundColor = bubbleSyncColor
        listTableView.superview?.backgroundColor = bubbleSyncColor
        
        //tableView
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.rowHeight = UITableViewAutomaticDimension
        listTableView.estimatedRowHeight = 77
        listTableView.allowsSelection = false
        listTableView.register(UINib(nibName: Identifier.listCell.rawValue, bundle: nil), forCellReuseIdentifier: Identifier.listCell.rawValue)
        listTableView.translatesAutoresizingMaskIntoConstraints = false
        listTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        listTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11, *) {
            listTableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        } else {
            listTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }
        
        completedListButton.backgroundColor = bubbleSyncColor.darkened().lighter(amount: 0.05)
        completedListButton.layer.borderWidth = 2
        completedListButton.layer.borderColor = bubbleSyncColor.darkened().lighter(amount: 0.44).cgColor
        completedListButton.layer.masksToBounds = true
        completedListButton.layer.cornerRadius = completedListButton.frame.width/2
        completedListButton.imageView?.contentMode = .scaleAspectFit
        completedListButton.normalSetup(normalImage: #imageLiteral(resourceName: "Checked List"), selectedImage: #imageLiteral(resourceName: "List"), tintColor: .white)
        completedListButton.addTarget(self, action: #selector(displayCompletedList), for: .touchUpInside)
        
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
    
    @objc func completeEvent(_ sender: UIButton) {
        guard let senderEvent = readEvent(at: sender.tag) else {
            return
        }
        EventManager.shared.create(calendarEvent: senderEvent.calendarEventID, content: senderEvent.content, note: nil, category: listTitle.appending("Completed"))
        deleteEvent(at: IndexPath(row: sender.tag, section: 0))
        
        guard let cell = listTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) else {
            return
        }
        let skView = SKView(frame: CGRect(x: sender.frame.midX, y: cell.frame.midY, width: sender.frame.width*2, height: self.view.frame.height - cell.frame.midY))
        skView.backgroundColor = .orange
        self.view.addSubview(skView)
        let scene = SpringScene(size: skView.bounds.size)
//        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        scene.createSceneContents()
    }
    
    @objc func backHome(_ sender: Any) {
        displayHomeView()
    }
    
    @objc func addEvent(_ sender: Any) {
        EventManager.shared.create(calendarEvent: nil, content: nil, note: nil, category: listTitle)
    }
    
    func readEvent(at row: Int) -> EventMO? {
        guard let object = fetchedResultsController.fetchedObjects?[row]else { return nil }
        
        return object
    }
    
    func deleteEvent(at indexPath: IndexPath) {
        guard let objectID = fetchedResultsController.fetchedObjects?[indexPath.row].objectID else { return }
        
        EventManager.shared.delete(id: objectID)

        if let cell = listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
            cell.detailBtnLeadingConstraint?.constant = view.frame.width + 100
            cell.contentView.layoutIfNeeded()
        }
    }
    
    @objc func removeAllEvent(_ sender: Any) {
        let myAlert = UIAlertController(title: "Refresh all?", message: "Clear all completed items.", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.destructive) { (_) in
            EventManager.shared.deleteAll()
        }
        myAlert.addAction(okAction)
        myAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @objc func displayCompletedList() {
        let strCompleted = "Completed"
        if completedListButton.isSelected {
            completedListButton.isSelected = false
            listTitle = self.listTitle.replacingOccurrences(of: strCompleted, with: "")
            navigationItem.title = self.listTitle
            addEventButton.removeTarget(self, action: #selector(removeAllEvent), for: .touchUpInside)
            addEventButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
            addEventButton.normalSetup(normalImage: #imageLiteral(resourceName: "Plus-50"), selectedImage: nil, tintColor: .black)
            listTableView.rotate(duration: 0.3, times: 1, completion: {
                self.fetchCoreDataResult()
                self.listTableView.reloadData()
                self.addCompleteButtonMethodOfAllCells()
            })
        } else {
            completedListButton.isSelected = true
            listTitle.append(strCompleted)
            navigationItem.title = strCompleted
            addEventButton.removeTarget(self, action: #selector(addEvent), for: .touchUpInside)
            addEventButton.addTarget(self, action: #selector(removeAllEvent), for: .touchUpInside)
            addEventButton.normalSetup(normalImage: #imageLiteral(resourceName: "Refresh"), selectedImage: nil, tintColor: .white)
            listTableView.rotate(duration: 0.3, times: 1, completion: {
                self.fetchCoreDataResult()
                self.listTableView.reloadData()
                self.removeCompleteButtonMethodOfAllCells()
            })
        }
    }
    
    func addCompleteButtonMethodOfAllCells() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        for i in 0...fetchedObjects.count {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                cell.completeEventButton.addTarget(self, action: #selector(completeEvent(_:)), for: .touchUpInside)
            }
        }
    }
    
    func removeCompleteButtonMethodOfAllCells() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        for i in 0...fetchedObjects.count {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                cell.completeEventButton.removeTarget(self, action: #selector(completeEvent(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func displayDetailPage(sender: UIButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            
            viewController.bubbleSyncColor = self.bubbleSyncColor
            if let event = EventManager.shared.read(row: sender.tag) {
                viewController.entryRow = sender.tag
                if let noteData = event.note {
                    viewController.noteData = noteData
                }
            }
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }

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
        //note: after saveContext the ID will totoally different
        EventManager.shared.appDelegate.saveContext()
        
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
                    refreshCellButtonTag(from: indexPath.row, to: cellCount)
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
    
    func refreshCellButtonTag(from startRow: Int, to endRow: Int) {
        if startRow > endRow { return }
        for i in startRow...endRow {
            if let cell = listTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ListTableViewCell {
                cell.indexRow = i - 1
                cell.viewDetailBtn.tag = i - 1
                cell.completeEventButton.tag = i - 1
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
                deleteEvent(at: indexPath)
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
        
        dequeCell.calendarPopupViewDelegate = self
        dequeCell.backgroundColor = bubbleSyncColor
        dequeCell.indexRow = indexPath.row
        dequeCell.viewDetailBtn.tag = indexPath.row
        dequeCell.completeEventButton.tag = indexPath.row
        dequeCell.viewDetailBtn.addTarget(self, action: #selector(displayDetailPage), for: .touchUpInside)
        dequeCell.completeEventButton.addTarget(self, action: #selector(completeEvent), for: .touchUpInside)
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


extension ListViewController: calendarPopupViewProtocol {
    
    func addViewControllerAsChild(viewController: CalendarViewController) {
        self.addChildViewController(viewController)
    }
}













