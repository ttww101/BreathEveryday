//
//  ContentManager.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/11.
//  Copyright © 2017年 Bomi. All rights reserved.
//
//
//  ArticleManager.swift
//  DemoCoreData
//
//  Created by Lucy on 2017/4/10.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import CoreData
import UIKit

class EventManager {
    
    static let shared = EventManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventMO")
    
    let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
    
    //C
    func create(calendarEvent: String?, content: String?, note: String?, category: String) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "EventMO", in: moc) else {
            
            return
            
        }
        
        let event = EventMO(entity: entityDescription, insertInto: moc)
        
        if let calendarEvent = calendarEvent {
            event.calendarEventID = calendarEvent
        }
        
        if let content = content {
            event.content = content
        }
        
        if let note = note {
            event.note = note
        }
        
        event.createdDate = NSDate()
        
        event.category = category
        
    }
    
    //R
    func read(row: Int) -> EventMO? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [EventMO] else {
                return nil
            }
            
            return results[row]
            
        } catch {
            
            fatalError("Core Data Read: \(error)")
        }
        
    }
    
    func readAll() -> [EventMO]? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [EventMO] else {
                return nil
            }
            
            return results
            
        } catch {
            
            fatalError("Core Data Read: \(error)")
        }
        
    }
    
    //U
    func update(id: NSManagedObjectID, content: String?, note: String?, calendarEvent: String?, alarmDate: NSDate?, isSetNotification: Bool?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let event = try moc.existingObject(with: id)
            
            guard let eventMO = event as? EventMO else {
                return
            }
            
            if let calendarEvent = calendarEvent {
                eventMO.calendarEventID = calendarEvent
            }
            
            if let content = content {
                eventMO.content = content
            }
            
            if let note = note {
                eventMO.note = note
            }
            
            if let alarmDate = alarmDate {
                eventMO.alarmStartTime = alarmDate
            }
            
            if let isSetNotification = isSetNotification {
                eventMO.isSetNotification = isSetNotification
            }
            
        } catch {
            
            fatalError("Core Data Update: \(error)")
        }
        
    }
    
    func update(row: Int, content: String?, note: String?, calendarEvent: String?, alarmDate: NSDate?, isSetNotification: Bool?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            
            guard let results = try moc.fetch(request) as? [EventMO] else {
                return
            }
            
            let event = results[row]
            
            if let calendarEvent = calendarEvent {
                event.calendarEventID = calendarEvent
            }
            
            if let content = content {
                event.content = content
            }
            
            if let note = note {
                event.note = note
            }
            
            if let alarmDate = alarmDate {
                event.alarmStartTime = alarmDate
            }
            
            if let isSetNotification = isSetNotification {
                event.isSetNotification = isSetNotification
            }
            
        } catch {
            
            fatalError("Core Data Update: \(error)")
        }
        
    }
    
    //D
    func delete(id: NSManagedObjectID) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let event = try moc.existingObject(with: id)
            
            moc.delete(event)
            
        } catch {
            
            fatalError("Core Data Delete: \(error)")
        }
        
    }
    
    func deleteAll() {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [EventMO] else {
                return
            }
            
            for result in results {
                
                moc.delete(result)
                
            }
            
            appDelegate.saveContext()
            
        } catch {
            
            fatalError("Core Data Delete: \(error)")
        }
        
    }
    
}














