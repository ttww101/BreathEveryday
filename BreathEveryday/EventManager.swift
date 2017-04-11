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

class ContentManager {
    
    static let shared = ContentManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ContentMO")
    
    //C
    func create(calendarEvent: String?, content: String?, detail: String?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "ContentMO", in: moc) else {
            
            return
            
        }
        
        let contentMO = ContentMO(entity: entityDescription, insertInto: moc)
        
        if let calendarEvent = calendarEvent {
            contentMO.calendarEvent = calendarEvent
        }
        
        if let content = content {
            contentMO.content = content
        }
        
        if let detail = detail {
            contentMO.detail = detail
        }
        
        contentMO.createdDate = NSDate()
        
    }
    
    //R
    func read(id: NSManagedObjectID) -> ContentMO? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let content = try moc.existingObject(with: id)
            
            guard let contentMO = content as? ContentMO else {
                return nil
            }
            
            return contentMO
            
        } catch {
            
            fatalError("\(error)")
        }
        
    }
    
    func readAll() -> [ContentMO]? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [ContentMO] else {
                return nil
            }
            
            return results
            
        } catch {
            
            fatalError("\(error)")
        }
        
    }
    
    //U
    func update(id: NSManagedObjectID, calendarEvent: String?, content: String?, detail: String?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let article = try moc.existingObject(with: id)
            
            guard let contentMO = article as? ContentMO else {
                return
            }
            
            if let calendarEvent = calendarEvent {
                contentMO.calendarEvent = calendarEvent
            }
            
            if let content = content {
                contentMO.content = content
            }
            
            if let detail = detail {
                contentMO.detail = detail
            }
            
            appDelegate.saveContext()
            
        } catch {
            
            fatalError("\(error)")
        }
        
    }
    
    //D
    func delete(id: NSManagedObjectID) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let content = try moc.existingObject(with: id)
            
            moc.delete(content)
            
        } catch {
            
            fatalError("\(error)")
        }
        
    }
    
    func deleteAll() {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [ContentMO] else {
                return
            }
            
            for result in results {
                
                moc.delete(result)
                
            }
            
            appDelegate.saveContext()
            
        } catch {
            
            fatalError("\(error)")
        }
        
    }
    
}














