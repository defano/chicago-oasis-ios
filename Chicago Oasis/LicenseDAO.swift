//
//  LicenseDAO.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LicenseDAO {
    
    static var licenses: [LicenseRecord] = []
    
    static func loadLicenses(onSuccess: () -> Void, onFailure:() -> Void) {
        let url = "http://www.chicago-oasis.org/json/licenses.json"
    
        // This data never changes; return cached copy when available
        if (licenses.count > 0) {
            onSuccess()
            return
        }
        
        Alamofire.request(.GET, url).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                for (_, element) in json {
                    licenses.append(LicenseRecord(
                        id: element["value"].stringValue,
                        title: element["title"].stringValue,
                        earliestYear: element["min-year"].intValue,
                        latestYear: element["max-year"].intValue)
                    )
                }
                
                onSuccess()
            }
        }
    }    
}