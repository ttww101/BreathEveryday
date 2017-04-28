//
//  DetailViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import Spring
//import SpriteKit

class DetailViewController: UIViewController {
    
    var entryRow: Int = 0
    var noteData: String = ""
    @IBOutlet weak var textView: UITextView!
    var textViewBottomConstraint: NSLayoutConstraint?
    var isTyping = false
    var bubbleSyncColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.bubbleSyncColor
        
        textView.delegate = self
        textView.text = noteData
        
        //notification for constraints
        textViewBottomConstraint = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        view.addConstraint(textViewBottomConstraint!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    //Notification Center
    func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            if let rectInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                
                //get rect
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                
                textViewBottomConstraint?.constant = isKeyboardShowing ? -rectInfo.height : -10
                
                isTyping = isKeyboardShowing ? true : false
                
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                    
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.35, animations: {
                        
//                        if let firstCell = self.listTableView.cellForRow(at: IndexPath(row: 1, section: listSectionType.add.hashValue)) as? ListTableViewCell {
//                            firstCell.contentView.frame = CGRect(x: firstCell.contentView.frame.minX , y: firstCell.contentView.frame.minY, width: firstCell.contentView.frame.width, height: firstCell.contentView.frame.height)
//                        }
                        
                    })
                })
                
            }
        }
    }
    
}


extension DetailViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        EventManager.shared.update(row: entryRow, content: nil, note: textView.text,calendarEvent: nil, alarmDate: nil, alarmIntervalOffset: nil, isSetNotification: nil)
        
        if let event = EventManager.shared.read(row: entryRow) {
            
            if let calendarEventID = event.calendarEventID,
                let content = event.content,
                let note = event.note,
                let date = event.alarmStartTime{
                
                let alarmIntervalOffset = event.alarmIntervalOffset
                let isNotification = event.isSetNotification
                print(content)
                print(note)
                print(date)
                print(event.alarmIntervalOffset)
                
                
                removeEvent(identifier: calendarEventID)
                
                //FIXME: relative offset
                let calendarIdentifier = insertEvent(title: content, notes: note, startDate: date as Date, EndDate: date as Date, relativeOffset: alarmIntervalOffset)
                
                EventManager.shared.update(row: entryRow,
                                           content: content,
                                           note: note,
                                           calendarEvent: calendarIdentifier,
                                           alarmDate: date,
                                           alarmIntervalOffset: alarmIntervalOffset,
                                           isSetNotification: isNotification)
            }
            
            EventManager.shared.appDelegate.saveContext()
        }
        
        

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    
}











