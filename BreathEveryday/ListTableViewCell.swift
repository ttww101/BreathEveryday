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

class ListTableViewCell: UITableViewCell {
    
    //appearance
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewDetailImage: UIImageView!
    var viewDetailBtn = UIButton()
    var starBtn: UIButton!
    lazy var alarmView = UIView()
    let calendarView = UIView()
    @IBOutlet weak var JTcalendarView: JTAppleCalendarView!
    let locationView = UIView()
    //event info
    var indexRow: Int = 0
    var isSetNotification: Bool = false
    var alarmPicker = UIPickerView()
    var eventID: NSManagedObjectID?
    var dateAlarmSet: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        addDetailBtn()
        addToolBarOnKeyboard()
        
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

// PickerView
//-----------------------------------
extension ListTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
//        switch component {
//            
//        case 0:
//            
//            
//            
//        }
        
    }
    
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
        
        print(isSetNotification)
        //set tool bar status
        if isSetNotification {
            starBtn.setImage(#imageLiteral(resourceName: "Star Filled-50"), for: .normal)
            setSelectedDate()
        } else {
            starBtn.setImage(#imageLiteral(resourceName: "Star-48"), for: .normal)
        }
        
        // TODO: Read Remind Data
//        readRemindData()
        
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
    
        // TODO: Set the alarm & store data
        
        guard let date = self.transferStringToDate(year: 2017,
                                                   month: 4,
                                                   day: 11,
                                                   hr: alarmPicker.selectedRow(inComponent: 0),
                                                   min: alarmPicker.selectedRow(inComponent: 2))
            else {
                print("wrong time!!!")
                return
            }
        
        dateAlarmSet = date
        
        //get ex event, remove ex calendarevent
        if let id = self.eventID,
            let event = EventManager.shared.read(id: id),
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
    
    func readRemindData() {
        
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

//JTCalendar
//-----------------------------------
//extension UITableViewCell: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

//    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy MM dd"
//        
//        let startDate = formatter.date(from: "2016 02 01")! // You can use date generated from a formatter
//        let endDate = Date()                                // You can also use dates created from this function
//        let parameters = ConfigurationParameters(startDate: startDate,
//                                                 endDate: endDate,
//                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
//            calendar: Calendar.current,
//            generateInDates: .forAllMonths,
//            generateOutDates: .tillEndOfGrid,
//            firstDayOfWeek: .sunday)
//        return parameters
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
//        let myCustomCell = cell as! CellView
//        
//        // Setup Cell text
//        myCustomCell.dayLabel.text = cellState.text
//        
//        // Setup text color
//        if cellState.dateBelongsTo == .thisMonth {
//            myCustomCell.dayLabel.textColor = UIColor.black
//        } else {
//            myCustomCell.dayLabel.textColor = UIColor.gray
//        }
//    }
//}

// Appearance
//------------------------------------
extension ListTableViewCell {
    
    func setSelectedDate() {
        
        if let date = dateAlarmSet {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            print(hour)
            alarmPicker.selectRow(hour, inComponent: 0, animated: true)
            let min = calendar.component(.minute, from: date)
            print(min)
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
            setSelectedDate()
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
        let width: CGFloat = 250
        superView.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: xPos - (width - 60) / 2).isActive = true
        calendarView.heightAnchor.constraint(equalToConstant: width).isActive = true
        calendarView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
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





