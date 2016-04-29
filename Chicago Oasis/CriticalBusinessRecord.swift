//
//  File.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

class CriticalBusinessRecord {
    let lat: Double
    let lng: Double
    let address: String
    let dbaName: String
    let atRiskPop: Int
    
    init (lat: Double, lng: Double, address: String, dbaName: String, atRiskPop: Int) {
        self.lat = lat
        self.lng = lng
        self.address = address
        self.dbaName = dbaName
        self.atRiskPop = atRiskPop
    }
}