//
//  Polygon.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import MapKit

class Polygon {
    var id:String
    var name:String
    var overlay:MKOverlay?
    
    init (id: String, name: String) {
        self.id = id
        self.name = name
    }
}
