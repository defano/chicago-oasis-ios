//
//  LicenseService.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LicenseService {
    
    static let sharedInstance = LicenseService()
    private init() {}
    
    var licenses: [License] = []
    
    func loadLicenses(_ onSuccess: @escaping () -> Void, onFailure:@escaping () -> Void) {
        let url = "http://www.chicago-oasis.org/json/licenses.json"
    
        // This data never changes; return cached copy when available
        if (licenses.count > 0) {
            onSuccess()
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                for (_, element) in json {
                    self.licenses.append(License(
                        id: element["value"].stringValue,
                        title: element["title"].stringValue,
                        earliestYear: element["min-year"].intValue,
                        latestYear: element["max-year"].intValue)
                    )
                }
                
                // Alphabetize by license title
                self.licenses.sort(by: {$0.title < $1.title})
                
                onSuccess()
            }
        }
    }    
}

struct License {
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
