//
//  CalendarEventModel.swift
//  FeatherList
//
//  Created by Lucy on 2017/4/6.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import EventKit
import UIKit

func insertEvent(title: String, notes: String, startDate: Date, EndDate: Date, relativeOffset: Double) -> String? {
    
    let eventStore = EKEventStore()
    let newEvent:EKEvent = EKEvent(eventStore: eventStore)
    
    newEvent.title = title
    newEvent.startDate = startDate
    newEvent.endDate = EndDate
    newEvent.notes = notes
    newEvent.calendar = eventStore.defaultCalendarForNewEvents
    newEvent.addAlarm(EKAlarm(relativeOffset: relativeOffset))
    
    do {
        try eventStore.save(newEvent, span: .thisEvent, commit: true)
        print("Saved Event")
        return newEvent.eventIdentifier
    } catch {
        let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        
        //FIXME: can't present alert
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
        return nil
    }
    
}

func removeEvent(identifier: String) {
    
    let eventStore = EKEventStore()
    guard let removeEvent = eventStore.event(withIdentifier: identifier) else {
        print("no specific event to delete")
        return
    }
    
    do {
        
        try eventStore.remove(removeEvent, span: .thisEvent)
        print("Delete Event")
        
    } catch {
        
        //TODO: err
        print("err")
        
    }
    
}

var arrHours: [String] {
    get {
        var arr:[String] = []
        for i in 0...23 {
            let str = String(format: "%02d", i)
            arr.append(str)
        }
        return arr
    }
}

var arrMinutes: [String] {
    get {
        var arr:[String] = []
        for i in 0...59 {
            let str = String(format: "%02d", i)
            arr.append(str)
        }
        return arr
    }
}

var arrAlertTime: [String] {
    get {
        var arr:[String] = []
        
        arr.append("0 mins")
        arr.append("5 mins")
        arr.append("15 mins")
        arr.append("1 hour")
        arr.append("2 hours")
        arr.append("1 day")
        arr.append("2 days")
        
        return arr
    }
}

var arrAlertTimeInterval: [Double] {
    get {
        var arr:[Double] = []
        
        arr.append(0)
        arr.append(5 * 60)
        arr.append(15 * 60)
        arr.append(60 * 60)
        arr.append(120 * 60)
        arr.append(24 * 60 * 60)
        arr.append(48 * 60 * 60)
        
        return arr
    }
}






