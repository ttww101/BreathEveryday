//
//  CalendarEventModel.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/6.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import EventKit
import UIKit

func insertEvent(title: String, notes: String, startDate: Date, EndDate: Date) -> String? {
    
    let eventStore = EKEventStore()
    let newEvent:EKEvent = EKEvent(eventStore: eventStore)
    
    newEvent.title = title
    newEvent.startDate = startDate
    newEvent.endDate = EndDate
    newEvent.notes = notes
    newEvent.calendar = eventStore.defaultCalendarForNewEvents
    newEvent.addAlarm(EKAlarm(relativeOffset: 0))
    
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






