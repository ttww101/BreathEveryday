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
    @IBOutlet weak var finishEventButton: UIButton!
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
    lazy var remindtimeView = UIView()
    lazy var alarmPicker = UIPickerView()
    lazy var remindTimePicker = UIPickerView()
    lazy var calendarView = UIView()
    var calendarJTVC: CalendarViewController? = nil
    weak var calendarPopupViewDelegate:calendarPopupViewProtocol?
    lazy var locationView = UIView()
    //event info
    var indexRow: Int = 0
    var isSetNotification: Bool = false
    var eventID: NSManagedObjectID?
    var alarmDateSet: Date?
    var alarmIntervalOffset: Double?
    var isBtnAlarmSet = false
    var isBtnRemindTimeSet = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        finishEventButton.imageView?.contentMode = .scaleAspectFit
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
        
        alarmDateSet = event.alarmStartTime as Date?
        
        alarmIntervalOffset = event.alarmIntervalOffset
        
    }
    
}

// Mark: PickerView
//-----------------------------------
extension ListTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if pickerView == alarmPicker {
            return 30
        } else {
            return 30
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        if pickerView == alarmPicker {
            if component == 1 {
                return 15
            } else {
                return 55
            }
        } else {
            return 160
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == alarmPicker {
            return 3
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == alarmPicker {
            if component == 0 {
                return arrHours.count
            } else if component == 2 {
                return arrMinutes.count
            } else {
                return 1
            }
        } else {
            return arrAlertTime.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if pickerView == alarmPicker {
            
            if component == 0 {
                let attributedString = NSAttributedString(string: arrHours[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
                return attributedString
            } else if component == 2 {
                let attributedString = NSAttributedString(string: arrMinutes[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
                return attributedString
            } else {
                return NSAttributedString(string: ":", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            }
            
        } else {
            
            return NSAttributedString(string: arrAlertTime[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            
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
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.contentView.layoutIfNeeded()
        }, completion: { (completed) in })
        
        //save contents
        saveContent()
        
        if isSetNotification {
            saveRemindData()
        }
        
        //disappear toolbar
        if !self.remindtimeView.isHidden {
            self.remindtimeView.isHidden = true
        }
        if !self.calendarView.isHidden {
            self.calendarView.isHidden = true
        }
        if !self.alarmView.isHidden {
            self.alarmView.isHidden = true
        }
        
        isBtnAlarmSet = false
        isBtnRemindTimeSet = false
        print("End Editing")
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
            setNotificationStatus(isEnable: true)
            setupAlarmPickerSelectedRow()
            setupRemindTimePickerSelectedRow()
        } else {
            setNotificationStatus(isEnable: false)
        }
        
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
                                   note: nil,
                                   calendarEvent: nil,
                                   alarmDate: nil,
                                   alarmIntervalOffset: nil,
                                   isSetNotification: isSetNotification)
        
    }
    
    func saveRemindData() {
    
        var year = 0
        var month = 0
        var day = 0
        var hour = 0
        var minutes = 0
        
        //process hour & min
        if isBtnAlarmSet {
            
            let selectedHour = alarmPicker.selectedRow(inComponent: 0)
            let selectedMin =  alarmPicker.selectedRow(inComponent: 0)
            if selectedHour >= 0 {
                hour = alarmPicker.selectedRow(inComponent: 0)
            }
            if selectedMin >= 0 {
                minutes = alarmPicker.selectedRow(inComponent: 2)
            }
            
        } else {
            
            if let date = alarmDateSet {
                let calendar = Calendar.current
                let hourCal = calendar.component(.hour, from: date)
                let minCal = calendar.component(.minute, from: date)
                hour = hourCal
                minutes = minCal
            } else {
                let date = Date()
                let calendar = Calendar.current
                var hourCal = calendar.component(.hour, from: date)
                if hourCal + 1 >= 24 {
                    hourCal = 0
                }
                hour = hourCal
            }
            
        }
        
        // set the alarm & store data
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
        
        alarmDateSet = date
        
        var savedNote = ""
        
        if let event = EventManager.shared.read(row: indexRow) {
            
            //get ex event, remove ex calendarevent
            if let calendarEventID = event.calendarEventID {
                removeEvent(identifier: calendarEventID)
            }
            
            //get saved note
            if let note = event.note {
                savedNote = note
            }
            
        }
        
        //process remindTime
        var relativeOffset:Double = 0
        if isBtnRemindTimeSet {
            let remindtimeSelectedRow = remindTimePicker.selectedRow(inComponent: 0)
            relativeOffset = arrAlertTimeInterval[remindtimeSelectedRow]
            alarmIntervalOffset = relativeOffset
        } else {
            if let intervalOffset = alarmIntervalOffset {
                relativeOffset = intervalOffset
            }
        }
        
        //insert event
        let calendarIdentifier = insertEvent(title: textView.text, notes: savedNote, startDate: date, EndDate: date, relativeOffset: relativeOffset * -1)
        
        //store event identifier
        if let calendarIdentifier = calendarIdentifier {
            
            EventManager.shared.update(row: indexRow,
                                       content: nil,
                                       note: nil,
                                       calendarEvent: calendarIdentifier,
                                       alarmDate: date as NSDate,
                                       alarmIntervalOffset: alarmIntervalOffset,
                                       isSetNotification: isSetNotification)
            
        }
        
    }
    
}

// MARK: Toolbar
//------------------------------------------
extension ListTableViewCell {
    func addToolBarOnKeyboard() {
        
        let toolBar = UIToolbar()
        
        let alarmBtn = CustomButton.alarm.button
        alarmBtn.addTarget(self, action: #selector(btnAlarmToolBar), for: .touchUpInside)
        adjustFrame(button: alarmBtn, width: UIScreen.main.bounds.width/6, height: alarmBtn.frame.height, image: nil)

        let remindTimeBtn = CustomButton.remindTime.button
        remindTimeBtn.addTarget(self, action: #selector(btnRemindTimeToolBar), for: .touchUpInside)
        adjustFrame(button: remindTimeBtn, width: UIScreen.main.bounds.width/6, height: remindTimeBtn.frame.height, image: nil)

        let calendarBtn = CustomButton.calender.button
        calendarBtn.addTarget(self, action: #selector(btnCalendarToolBar), for: .touchUpInside)
        adjustFrame(button: calendarBtn, width: UIScreen.main.bounds.width/6, height: calendarBtn.frame.height, image: nil)
        
        starBtn = CustomButton.star.button
        starBtn.addTarget(self, action: #selector(btnStarToolBar), for: .touchUpInside)
        adjustFrame(button: starBtn, width: UIScreen.main.bounds.width/6, height: starBtn.frame.height, image: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.setItems([UIBarButtonItem(customView: starBtn),
                          flexibleSpace,
                          UIBarButtonItem(customView: calendarBtn),
                          flexibleSpace,
                          UIBarButtonItem(customView: alarmBtn),
                          flexibleSpace,
                          UIBarButtonItem(customView: remindTimeBtn),
                          flexibleSpace,
                          doneBtn]
            , animated: false)
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
    }

    @objc func btnStarToolBar(sender: UIButton) {
        if isSetNotification {
            setNotificationStatus(isEnable: false)
        }
    }

    @objc func btnCalendarToolBar(sender: UIButton) {
        
        if calendarView.superview == nil {
            
            createCalendarPopView(xPos: sender.frame.midX)
            if !isSetNotification {
                setNotificationStatus(isEnable: true)
            }
            
        } else {
            if calendarView.isHidden {
                
                calendarView.isHidden = false
                if !isSetNotification {
                    setNotificationStatus(isEnable: true)
                }
                
            } else {
                calendarView.isHidden = true
            }
        }
        
        if !alarmView.isHidden {
            alarmView.isHidden = true
        }
        if !remindtimeView.isHidden {
            remindtimeView.isHidden = true
        }
        
    }

    func setNotificationStatus(isEnable: Bool) {
        if isEnable {
            isSetNotification = true
            if #available(iOS 11, *) {
                starBtn.setImage(#imageLiteral(resourceName: "Star Filled-ios11"), for: .normal)
            } else {
                starBtn.setImage(#imageLiteral(resourceName: "Star-Filled"), for: .normal)
            }
        } else {
            isSetNotification = false
            if #available(iOS 11, *) {
                starBtn.setImage(#imageLiteral(resourceName: "Star-ios11"), for: .normal)
            } else {
                starBtn.setImage(#imageLiteral(resourceName: "Star"), for: .normal)
            }
        }
    }
    
    @objc func btnAlarmToolBar(sender: UIButton) {
        
        if alarmView.superview == nil {
            isBtnAlarmSet = true
            print(sender.frame.midX)
            createAlarmPopView(xPos: sender.frame.midX)
            if !isSetNotification {
                setNotificationStatus(isEnable: true)
            }
        } else {
            isBtnAlarmSet = true
            if alarmView.isHidden { //display
                alarmView.isHidden = false
                if !isSetNotification {
                    setNotificationStatus(isEnable: true)
                }
            } else {
                alarmView.isHidden = true
            }
        }
        
        setupAlarmPickerSelectedRow()

        if !calendarView.isHidden {
            calendarView.isHidden = true
        }
        if !remindtimeView.isHidden {
            remindtimeView.isHidden = true
        }
    }
    
    @objc func btnRemindTimeToolBar(sender: UIButton) {
        
        if remindtimeView.superview == nil {
            isBtnRemindTimeSet = true
            createRemindTimePopView(xPos: sender.frame.midX)
        } else {
            if remindtimeView.isHidden {
                isBtnRemindTimeSet = true
                remindtimeView.isHidden = false
            } else {
                remindtimeView.isHidden = true
            }
        }
        
        setupRemindTimePickerSelectedRow()
        
        if !calendarView.isHidden {
            calendarView.isHidden = true
        }
        if !alarmView.isHidden {
            alarmView.isHidden = true
        }
    }

    @objc func dismissKeyboard() {
        
        contentView.endEditing(true)
        
    }

    func transferStringToDate(year: Int, month: Int, day: Int, hr: Int, min: Int) -> Date? {
        //note: 2400 == 0000
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: "\(year)-\(month)-\(day) \(hr):\(min):00")
        return date
        
    }
    
    func setupAlarmPickerSelectedRow() {
        
        if let date = alarmDateSet {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            alarmPicker.selectRow(hour, inComponent: 0, animated: false)
            let min = calendar.component(.minute, from: date)
            alarmPicker.selectRow(min, inComponent: 2, animated: false)
        } else {
            let date = Date()
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            if hour + 1 >= 24 {
                hour = 0
            }
            alarmPicker.selectRow(hour + 1, inComponent: 0, animated: true)
        }
    }
    
    func setupRemindTimePickerSelectedRow() {
        
        if let intervalOffset = alarmIntervalOffset {
            
            var selectRow = 0
            for i in 0...arrAlertTimeInterval.count {
                if intervalOffset == arrAlertTimeInterval[i] {
                    selectRow = i
                    break
                }
            }
            remindTimePicker.selectRow(selectRow, inComponent: 0, animated: true)
            
        } else {
            remindTimePicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
}

// MARK: Appearance
//------------------------------------
extension ListTableViewCell {
    
    func createAlarmPopView(xPos: CGFloat) {
        
        if #available(iOS 11, *) {
            guard let superView = textView.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview else {
                return
            }
            //view
            alarmView.backgroundColor = grayBlueColor
            alarmView.alpha = 0.96
            alarmView.layer.cornerRadius = 10
            alarmView.layer.masksToBounds = true
            alarmView.isHidden = false
            superView.addSubview(alarmView)
            alarmView.translatesAutoresizingMaskIntoConstraints = false
            alarmView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
            print(tableView.frame)
            print(tableView.center.x)
            alarmView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor, constant: xPos*2/9).isActive = true
            alarmView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            alarmView.widthAnchor.constraint(equalToConstant: 160).isActive = true
            
            //pickerView
            alarmPicker.delegate = self
            alarmPicker.dataSource = self
            alarmView.addSubview(alarmPicker)
            
            //constraints
            alarmPicker.translatesAutoresizingMaskIntoConstraints = false
            alarmPicker.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 0).isActive = true
            alarmPicker.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: 0).isActive = true
            alarmPicker.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 5).isActive = true
            alarmPicker.trailingAnchor.constraint(equalTo: alarmView.trailingAnchor, constant: -15).isActive = true
            
        } else {
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
            alarmView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor, constant: xPos - center.x).isActive = true
            alarmView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            alarmView.widthAnchor.constraint(equalToConstant: width).isActive = true
            
            //pickerView
            alarmPicker.delegate = self
            alarmPicker.dataSource = self
            alarmView.addSubview(alarmPicker)
            
            //constraints
            alarmPicker.translatesAutoresizingMaskIntoConstraints = false
            alarmPicker.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 0).isActive = true
            alarmPicker.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: 0).isActive = true
            alarmPicker.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 5).isActive = true
            alarmPicker.trailingAnchor.constraint(equalTo: alarmView.trailingAnchor, constant: -15).isActive = true
        }
    }
    
    func createRemindTimePopView(xPos: CGFloat) {
        if #available(iOS 11, *) {
            guard let superView = textView.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview else {
                return
            }
            
            remindtimeView.backgroundColor = grayBlueColor
            remindtimeView.alpha = 0.96
            remindtimeView.layer.cornerRadius = 10
            remindtimeView.layer.masksToBounds = true
            remindtimeView.isHidden = false
            superView.addSubview(remindtimeView)
            remindtimeView.translatesAutoresizingMaskIntoConstraints = false
            remindtimeView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
            remindtimeView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor, constant: 2*xPos + xPos*4/9).isActive = true
            remindtimeView.heightAnchor.constraint(equalToConstant: 110).isActive = true
            remindtimeView.widthAnchor.constraint(equalToConstant: 130).isActive = true
            
            //pickerView
            remindTimePicker.delegate = self
            remindTimePicker.dataSource = self
            remindtimeView.addSubview(remindTimePicker)
            
            let beforeLbl = UILabel()
            beforeLbl.text = "Before"
            beforeLbl.textColor = .white
            beforeLbl.font = UIFont.systemFont(ofSize: 20)
            beforeLbl.textAlignment = .center
            remindtimeView.addSubview(beforeLbl)
            
            //constraints
            beforeLbl.translatesAutoresizingMaskIntoConstraints = false
            remindTimePicker.translatesAutoresizingMaskIntoConstraints = false
            beforeLbl.topAnchor.constraint(equalTo: remindtimeView.topAnchor, constant: 8).isActive = true
            beforeLbl.bottomAnchor.constraint(equalTo: remindtimeView.topAnchor, constant: 35).isActive = true
            beforeLbl.leadingAnchor.constraint(equalTo: remindtimeView.leadingAnchor, constant: 10).isActive = true
            beforeLbl.trailingAnchor.constraint(equalTo: remindtimeView.trailingAnchor, constant: -5).isActive = true
            remindTimePicker.topAnchor.constraint(equalTo: beforeLbl.centerYAnchor, constant: 5).isActive = true
            remindTimePicker.bottomAnchor.constraint(equalTo: remindtimeView.bottomAnchor, constant: 0).isActive = true
            remindTimePicker.leadingAnchor.constraint(equalTo: remindtimeView.leadingAnchor, constant: -18).isActive = true
            remindTimePicker.trailingAnchor.constraint(equalTo: remindtimeView.trailingAnchor, constant: 0).isActive = true
        } else {
            guard let superView = textView.superview?.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview?.superview else {
                return
            }
            //view
            remindtimeView.backgroundColor = grayBlueColor
            remindtimeView.alpha = 0.96
            remindtimeView.layer.cornerRadius = 10
            remindtimeView.layer.masksToBounds = true
            remindtimeView.isHidden = false
            superView.addSubview(remindtimeView)
            remindtimeView.translatesAutoresizingMaskIntoConstraints = false
            remindtimeView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
            remindtimeView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor, constant: xPos - center.x).isActive = true
            remindtimeView.heightAnchor.constraint(equalToConstant: 110).isActive = true
            remindtimeView.widthAnchor.constraint(equalToConstant: 130).isActive = true
            
            //pickerView
            remindTimePicker.delegate = self
            remindTimePicker.dataSource = self
            remindtimeView.addSubview(remindTimePicker)
            
            let beforeLbl = UILabel()
            beforeLbl.text = "Before"
            beforeLbl.textColor = .white
            beforeLbl.font = UIFont.systemFont(ofSize: 20)
            beforeLbl.textAlignment = .center
            remindtimeView.addSubview(beforeLbl)
            
            //constraints
            beforeLbl.translatesAutoresizingMaskIntoConstraints = false
            remindTimePicker.translatesAutoresizingMaskIntoConstraints = false
            beforeLbl.topAnchor.constraint(equalTo: remindtimeView.topAnchor, constant: 8).isActive = true
            beforeLbl.bottomAnchor.constraint(equalTo: remindtimeView.topAnchor, constant: 35).isActive = true
            beforeLbl.leadingAnchor.constraint(equalTo: remindtimeView.leadingAnchor, constant: 10).isActive = true
            beforeLbl.trailingAnchor.constraint(equalTo: remindtimeView.trailingAnchor, constant: -5).isActive = true
            remindTimePicker.topAnchor.constraint(equalTo: beforeLbl.centerYAnchor, constant: 5).isActive = true
            remindTimePicker.bottomAnchor.constraint(equalTo: remindtimeView.bottomAnchor, constant: 0).isActive = true
            remindTimePicker.leadingAnchor.constraint(equalTo: remindtimeView.leadingAnchor, constant: -18).isActive = true
            remindTimePicker.trailingAnchor.constraint(equalTo: remindtimeView.trailingAnchor, constant: 0).isActive = true
        }
    }
    
    
    func createCalendarPopView(xPos: CGFloat) {
        if #available(iOS 11, *) {
            guard let superView = textView.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview else {
                return
            }
            calendarView.backgroundColor = grayBlueColor
            calendarView.alpha = 0.98
            calendarView.layer.cornerRadius = 10
            calendarView.layer.masksToBounds = true
            calendarView.isHidden = false
            superView.addSubview(calendarView)
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            calendarView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
            calendarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 2).isActive = true
            if tableView.frame.maxY - 300 >= 0 {
                calendarView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -300).isActive = true
            } else {
                calendarView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 0).isActive = true
            }
            calendarView.widthAnchor.constraint(equalToConstant: 295).isActive = true
            
            //initial calendrView
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
            calendarJTVC = vc
            vc.alarmDateSet = alarmDateSet
            vc.view.frame = self.calendarView.bounds
            calendarView.addSubview(vc.view)
            if self.calendarPopupViewDelegate != nil {
                self.calendarPopupViewDelegate?.addViewControllerAsChild(viewController: vc)
            }
        } else {
            //FIXME: iPhone 5S suitable size
            guard let superView = textView.superview?.superview?.superview?.superview?.superview , let tableView = textView.superview?.superview?.superview?.superview else {
                return
            }
            calendarView.backgroundColor = grayBlueColor
            calendarView.alpha = 0.98
            calendarView.layer.cornerRadius = 10
            calendarView.layer.masksToBounds = true
            calendarView.isHidden = false
            superView.addSubview(calendarView)
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            calendarView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -3).isActive = true
            calendarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 2).isActive = true
            if tableView.frame.maxY - 300 >= 0 {
            calendarView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -300).isActive = true
            } else {
                calendarView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 0).isActive = true
            }
            calendarView.widthAnchor.constraint(equalToConstant: 295).isActive = true
            
            //initial calendrView
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
            calendarJTVC = vc
            vc.alarmDateSet = alarmDateSet
            vc.view.frame = self.calendarView.bounds
            calendarView.addSubview(vc.view)
            if self.calendarPopupViewDelegate != nil {
                self.calendarPopupViewDelegate?.addViewControllerAsChild(viewController: vc)
            }
        }
    }
    
    //Default set up
    func addDetailBtn() {
        
        viewDetailBtn.layer.frame = CGRect(x: 0, y: 0, width: viewDetailImage.frame.width, height: viewDetailImage.frame.height)
        viewDetailBtn.alpha = 0.1
        viewDetailImage.addSubview(viewDetailBtn)
    }

}





