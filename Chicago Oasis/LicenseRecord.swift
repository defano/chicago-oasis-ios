//
//  LicenseRecord.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

class LicenseRecord {
    let title: String
    let id: String
    let earliestYear: Int
    let latestYear: Int
    
    init (id: String, title: String, earliestYear: Int, latestYear: Int) {
        self.id = id
        self.title = title
        self.earliestYear = earliestYear
        self.latestYear = latestYear
    }
}