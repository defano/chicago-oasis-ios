//
//  UserDefaults.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 5/7/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

class UserDefaults {

    static let polygonCacheEnabledIdentifier:String = "polygonCacheEnabled"
    
    static var polygonCacheEnabled:Bool {
        get {
            return Foundation.UserDefaults.standard.bool(forKey: polygonCacheEnabledIdentifier)
        }
    }
}
