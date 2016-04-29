//
//  AccessibilityRecord.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

class AccessibilityRecord {
    let id: String
    let index: Double
    var oneMile, twoMile, threeMile: Int?
    
    init (id: String, index: Double) {
        self.id = id
        self.index = index
    }
}