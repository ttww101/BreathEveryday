//
//  ListTableViewCell.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/20.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar

protocol calendarPopupViewProtocol: class {
    func addViewControllerAsChild(viewController :CalendarViewController)
}

class ListTableViewCell: UITableViewCell {
    
    //appearance
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewDetailImage: UIImageView!
    var viewDetailBtn = UIButton()
    var textViewLeadingConstraint: NSLayoutConstraint?
    var textViewTrailingConstraint: NSLayoutConstraint?
    var detailBtnLeadingConstraint: NSLayoutConstraint?
    let numTextViewLeftConstant:CGFloat = 40
    let numTextViewRightConstant:CGFloat = -20
    let numTextViewMoveLeftConstant:CGFloat = 25
    let numDetailImageToTextView: CGFloat = 25
    //toolBar
    var starBtn: UIButton!
    lazy var alarmView = UIView()
    lazy var alarmPicker = UIPickerView()
    lazy var calendarView = UIView()
    var calendarJTVC: CalendarViewController? = nil
    weak var calendarPopupViewDelegate:calendarPopupViewProtocol?
    lazy var locationView = UIView()
    //event info
    var indexRow: Int = 0
    var isSetNotification: Bool = false
    var eventID: NSManagedObjectID?
    var dateAlarmSet: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        addDetailBtn()
        addToolBarOnKeyboard()
        textViewLeadingConstraint = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: numTextViewLeftConstant)
        textViewTrailingConstraint = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: numTextViewRightConstant)
        detailBtnLeadingConstraint = NSLayoutConstraint(item: viewDetailImage, attribute: .leading, relatedBy: .equal, toItem: textView, attribute: .trailing, multiplier: 1, constant: numDetailImageToTextView)

        contentView.addConstraint(textViewLeadingConstraint!)
        contentView.addConstraint(textViewTrailingConstraint!)
        contentView.addConstraint(detailBtnLeadingConstraint!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView?.becomeFirstResponder()
        } else {
            textView?.resignFirstResponder()
        }
        
    }
    
    func configureCell(event: EventMO) {
        
        textView.text = event.content
        
        eventID = event.objectID
        
        isSetNotification = event.isSetNotification
        
        dateAlarmSet = event.alarmStartTime as Date?
        
    }
    
}

// Mark: PickerView
//-----------------------------------
extension ListTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 1 {
            return 15
        } else {
            return 55
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return arrHours.count
        } else if component == 2 {
            return arrMinutes.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if component == 0 {
            
            let attributedString = NSAttributedString(string: arrHours[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
            return attributedString
            
        } else if component == 2 {
            
            let attributedString = NSAttributedString(string: arrMinutes[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
            return attributedString
            
        } else {
            
            return NSAttributedString(string: ":", attributes: [NSForegroundColorAttributeName : UIColor.white])
            
        }
        
    }
    
    
}


// MARK: TextView
//-----------------------------------
extension ListTableViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //constraints change
        textViewLeadingConstraint?.constant = numTextViewLeftConstant
        textViewTrailingConstraint?.constant = numTextViewRightConstant
        detailBtnLeadingConstraint?.constant = numDetailImageToTextView
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
//            self.contentView.layoutIfNeeded()
//        }, completion: { (completed) in })
        
        //disappear toolbar
        if !self.locationView.isHidden {
            self.locationView.isHidden = true
        }
        if !self.calendarView.isHidden {
            self.calendarView.isHidden = true
        }
        
        if !self.alarmView.isHidden {
            self.alarmView.isHidden = true
        }
        
        //save contents
        print("End Editing")
        saveContent()
        
        if isSetNotification {
            saveRemindData()
        }
        
        EventManager.shared.appDelegate.saveContext()
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        //detect every typing word
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Begin Editing")
        
        //constraints change
        textViewLeadingConstraint?.constant = numTextViewLeftConstant - numTextViewMoveLeftConstant
        textViewTrailingConstraint?.constant = numTextViewRightConstant - numTextViewMoveLeftConstant
        detailBtnLeadingConstraint?.constant = 5
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.contentView.layoutIfNeeded()
        }, completion: { (completed) in })

        
        //set tool bar status
        if isSetNotification {
            starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
            setupSelectedTime()
        } else {
            starBtn.setImage(#imageLiteral(resourceName: "Star-48"), for: .normal)
        }
        
        //Read Remind Data?
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let tableView = textView.superview?.superview?.superview?.superview as? UITableView else {
            return
        }
        
        // Resize the cell when size's changing
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: 100))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
    }
    
    
}

// MARK: Process Event Data
//----------------------------------
extension ListTableViewCell {
    
    func saveContent() {

        EventManager.shared.update(row: indexRow,
                                   content: self.textView.text,
                                   detail: nil,
                                   calendarEvent: nil,
                                   alarmDate: nil,
                                   isSetNotification: isSetNotification)
        
    }
    
    func saveRemindData() {
    
        var year = 0
        var month = 0
        var day = 0
        let hour = alarmPicker.selectedRow(inComponent: 0)
        let minutes = alarmPicker.selectedRow(inComponent: 2)
        
        // TODO: Set the alarm & store data
        if let jtvc = calendarJTVC {
            let selectedDate = jtvc.calendarView.selectedDates[0]
            let calendar = Calendar.current
            year = calendar.component(.year, from: selectedDate)
            month = calendar.component(.month, from: selectedDate)
            day = calendar.component(.day, from: selectedDate)
        } else {
            let currentDate = Date()
            let calendar = Calendar.current
            year = calendar.component(.year, from: currentDate)
            month = calendar.component(.month, from: currentDate)
            day = calendar.component(.day, from: currentDate)
        }
        
        guard let date = self.transferStringToDate(year: year,
                                                   month: month,
                                                   day: day,
                                                   hr: hour,
                                                   min: minutes)
            else {
                print("wrong time!!!")
                return
            }
        
        dateAlarmSet = date
        
        //get ex event, remove ex calendarevent
        if let id = self.eventID,
            let event = EventManager.shared.read(row: indexRow),
            let calendarEventID = event.calendarEventID {
            removeEvent(identifier: calendarEventID)
        }
        
        //insert event
        let calendarIdentifier = insertEvent(title: textView.text, notes: "", startDate: date, EndDate: date)
        
        //TODO: store event identifier
        if let calendarIdentifier = calendarIdentifier {
            if let id = self.eventID {
                EventManager.shared.update(id: id,
                                           content: nil,
                                           detail: nil,
                                           calendarEvent: calendarIdentifier,
                                           alarmDate: date as NSDate,
                                           isSetNotification: isSetNotification)
            }
        }
        
        
        // TODO: Display the setup info of the event
        
    }
    
}

// MARK: Toolbar
//------------------------------------------
extension ListTableViewCell {
    func addToolBarOnKeyboard() {
        
        let toolBar = UIToolbar()
        
        let alarmBtn = CustomButton.alarm.button
        alarmBtn.addTarget(self, action: #selector(btnAlarmToolBar), for: .touchUpInside)
        let calendarBtn = CustomButton.calender.button
        calendarBtn.addTarget(self, action: #selector(btnCalendarToolBar), for: .touchUpInside)
        let locateBtn = CustomButton.locate.button
        locateBtn.addTarget(self, action: #selector(btnLocateToolBar), for: .touchUpInside)
        starBtn = CustomButton.star.button
        starBtn.addTarget(self, action: #selector(btnStarToolBar), for: .touchUpInside)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.setItems([UIBarButtonItem(customView: starBtn),
                          UIBarButtonItem(customView: locateBtn),
                          UIBarButtonItem(customView: calendarBtn),
                          UIBarButtonItem(customView: alarmBtn),
                          flexibleSpace,
                          doneBtn]
            , animated: false)
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
        
    }

    func btnStarToolBar(sender: UIButton) {
        
        if !isSetNotification {
            isSetNotification = true
            starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
        } else {
            isSetNotification = false
            starBtn.setImage(#imageLiteral(resourceName: "Star-48"), for: .normal)
        }
        
    }

    func btnLocateToolBar(sender: UIButton) {
        
        //        if !isSetNotification {
        //            isSetNotification = true
        //            starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
        //        }
        
        if locationView.superview == nil {
            createLocationPopView(xPos: sender.frame.minX)
        } else {
            if locationView.isHidden {
                locationView.isHidden = false
            } else {
                locationView.isHidden = true
            }
        }
        
        if !alarmView.isHidden {
            alarmView.isHidden = true
        }
        if !calendarView.isHidden {
            calendarView.isHidden = true
        }
    }

    func btnCalendarToolBar(sender: UIButton) {
        
        //        if !isSetNotification {
        //            isSetNotification = true
        //            starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
        //        }
        
        if calendarView.superview == nil {
            createCalendarPopView(xPos: sender.frame.minX)
        } else {
            if calendarView.isHidden {
                calendarView.isHidden = false
            } else {
                calendarView.isHidden = true
            }
        }
        
        if !alarmView.isHidden {
            alarmView.isHidden = true
        }
        if !locationView.isHidden {
            locationView.isHidden = true
        }
    }

    func btnAlarmToolBar(sender: UIButton) {
        
        if alarmView.superview == nil {
            createAlarmPopView(xPos: sender.frame.minX)
        } else {
            if alarmView.isHidden { //display
                alarmView.isHidden = false
            } else { //disappear
                alarmView.isHidden = true
                //                if !isSetNotification {
                //                    isSetNotification = true
                //                    starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
                //                }
            }
        }
        
        if !locationView.isHidden {
            locationView.isHidden = true
        }
        if !calendarView.isHidden {
            calendarView.isHidden = true
        }
    }

    func dismissKeyboard() {
        
        contentView.endEditing(true)
        
    }

    func transferStringToDate(year: Int, month: Int, day: Int, hr: Int, min: Int) -> Date? {
        //note: 2400 == 0000
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: "\(year)-\(month)-\(day) \(hr):\(min):00")
        return date
        
    }
}

// MARK: Appearance
//------------------------------------
extension ListTableViewCell {
    
    func setupSelectedTime() {
        
        if let date = dateAlarmSet {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            alarmPicker.selectRow(hour, inComponent: 0, animated: true)
            let min = calendar.component(.minute, from: date)
            alarmPicker.selectRow(min, inComponent: 2, animated: true)
        }
        
    }
    
    func createAlarmPopView(xPos: CGFloat) {
        
        guard let superView = textView.superview?.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview?.superview else {
            return
        }
        
        //view
        alarmView.backgroundColor = grayBlueColor
        alarmView.alpha = 0.96
        alarmView.layer.cornerRadius = 10
        alarmView.layer.masksToBounds = true
        alarmView.isHidden = false
        let width: CGFloat = 160
        superView.addSubview(alarmView)
        alarmView.translatesAutoresizingMaskIntoConstraints = false
        alarmView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
        alarmView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: xPos - (width - 60) / 2).isActive = true
        alarmView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        alarmView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        //pickerView
        alarmPicker.delegate = self
        alarmPicker.dataSource = self
        alarmView.addSubview(alarmPicker)
        //set current time
        if dateAlarmSet == nil {
            let date = Date()
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            if hour + 1 >= 24 {
                hour = 0
            }
            alarmPicker.selectRow(hour + 1, inComponent: 0, animated: true)
        } else {
            setupSelectedTime()
        }
        
        //constraints
        alarmPicker.translatesAutoresizingMaskIntoConstraints = false
        alarmPicker.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 0).isActive = true
        alarmPicker.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: 0).isActive = true
        alarmPicker.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 5).isActive = true
        alarmPicker.trailingAnchor.constraint(equalTo: alarmView.trailingAnchor, constant: -15).isActive = true
        
    }
    
    func createCalendarPopView(xPos: CGFloat) {
        
        guard let superView = textView.superview?.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview?.superview else {
            return
        }
        
        calendarView.backgroundColor = grayBlueColor
        calendarView.alpha = 0.98
        calendarView.layer.cornerRadius = 10
        calendarView.layer.masksToBounds = true
        calendarView.isHidden = false
        let width: CGFloat = 295
        superView.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: xPos - (width - 60) / 2).isActive = true
        calendarView.heightAnchor.constraint(equalToConstant: width).isActive = true
        calendarView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        //initial calendrView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        calendarJTVC = vc
        vc.dateAlarmSet = dateAlarmSet
        vc.view.frame = self.calendarView.bounds
        calendarView.addSubview(vc.view)
        if self.calendarPopupViewDelegate != nil {
            self.calendarPopupViewDelegate?.addViewControllerAsChild(viewController: vc)
        }
        
    }
    
    func createLocationPopView(xPos: CGFloat) {
        
        guard let superView = textView.superview?.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview?.superview else {
            return
        }
        
        locationView.backgroundColor = grayBlueColor
        locationView.alpha = 0.98
        locationView.layer.cornerRadius = 10
        locationView.layer.masksToBounds = true
        locationView.isHidden = false

        superView.addSubview(locationView)
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -40).isActive = true
        locationView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10).isActive = true
        locationView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 5).isActive = true
        locationView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -5).isActive = true
        
    }
    
    //Default set up
    func addDetailBtn() {
        
        viewDetailBtn.layer.frame = CGRect(x: 0, y: 0, width: viewDetailImage.frame.width, height: viewDetailImage.frame.height)
        viewDetailBtn.alpha = 0.1
        viewDetailImage.addSubview(viewDetailBtn)
        
    }

}





