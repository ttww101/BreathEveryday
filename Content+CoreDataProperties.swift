//
//  Content+CoreDataProperties.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/27.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content");
    }

    @NSManaged public var content: String?
    @NSManaged public var detail: String?
    @NSManaged public var row: Int32

}
