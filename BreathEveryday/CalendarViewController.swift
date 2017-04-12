//
//  CalendarViewController.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/12.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
    }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")! // You can use date generated from a formatter
        let endDate = formatter.date(from: "2017 12 31")!                                // You can also use dates created from this function
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
        
    }
    
    func handleCellSelectedColor(cell: JTAppleCell?, cellState: CellState) {
        
        guard let cell = cell as? CalendarCell else { return }
        
        if cellState.isSelected {
            cell.seletedView.isHidden = false
        } else {
            cell.seletedView.isHidden = true
        }
        
    }
    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        
        guard let cell = cell as? CalendarCell else { return }
        
        if cellState.isSelected {
            cell.dateLabel.textColor = .red
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = .white
            } else {
                cell.dateLabel.textColor = .lightGray
            }
        }
        
    }

}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    // Display cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return JTAppleCell()
        }
        
        cell.dateLabel.text = cellState.text
        handleCellSelectedColor(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        
        return cell
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectedColor(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelectedColor(cell: cell, cellState: cellState)
    }
    
    
}



















