//
//  CategoryManager.swift
//  FeatherList
//
//  Created by Lucy on 2017/4/17.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import CoreData
import UIKit

class CategoryManager {
    
    static let shared = CategoryManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var request = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryMO")
    
    let sortDescriptor = NSSortDescriptor(key: "isCreated", ascending: false)
    
    //C
    func create(name: String?, isCreated: Bool?, frame: CGRect?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "CategoryMO", in: moc) else {
            
            return
            
        }
        
        let category = CategoryMO(entity: entityDescription, insertInto: moc)
        
        if let name = name {
            category.name = name
        }
        
        if let isCreated = isCreated {
            category.isCreated = isCreated
        }
        
        if let frame = frame {
            category.posX = Float(frame.minX)
            category.posY = Float(frame.minY)
            category.width = Float(frame.width)
            category.height = Float(frame.height)
        }
        
        
    }
    
    //R
    func read(name: String) -> CategoryMO? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            
            guard let results = try moc.fetch(request) as? [CategoryMO] else {
                return nil
            }
            
            if results.count > 0 {
                
                return results[0]
                
            } else {
                
                return nil
                
            }
            
        } catch {
            
            fatalError("Core Data Read: \(error)")
        }
        
    }
    
    func readAll() -> [CategoryMO]? {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            guard let results = try moc.fetch(request) as? [CategoryMO] else {
                return nil
            }
            
            print(results)
            
            return results
            
        } catch {
            
            fatalError("Core Data Read: \(error)")
        }
        
    }
    
    //U
    func update(id: NSManagedObjectID, content: String?, detail: String?, calendarEvent: String?, alarmDate: NSDate?, isSetNotification: Bool?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            
            let event = try moc.existingObject(with: id)
            
            guard let CategoryMO = event as? CategoryMO else {
                return
            }
            
        } catch {
            
            fatalError("Core Data Update: \(error)")
        }
        
    }
    
    func update(row: Int, content: String?, detail: String?, calendarEvent: String?, alarmDate: NSDate?, isSetNotification: Bool?) {
        
        let moc = appDelegate.persistentContainer.viewContext
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            
            guard let results = try moc.fetch(request) as? [CategoryMO] else {
                return
            }
            
            let event = results[row]
            
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
            
            guard let results = try moc.fetch(request) as? [CategoryMO] else {
                return
            }
            print(results)
            
            for result in results {
                
                moc.delete(result)
                
            }
            
//            appDelegate.saveContext()
            
        } catch {
            
            fatalError("Core Data Delete: \(error)")
        }
        
    }
    
}














