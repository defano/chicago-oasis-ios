//
//  String+Localized.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 5/18/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

extension String {
    
    var localized:String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
}
