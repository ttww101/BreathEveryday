//
//  LCQuote.swift
//  BreathEveryday
//
//  Created by Wu on 2019/1/13.
//  Copyright © 2019 Bomi. All rights reserved.
//

import Foundation

struct LCQuote {
    
    static let idKey = "objectId"
    static let textKey = "Text"
    
    let id: String
    let text: String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
    
}
