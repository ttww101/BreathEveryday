//
//  Content+CoreDataClass.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/3/30.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Foundation
import CoreData


public class Content: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.createDate = NSDate()
        
    }

}
