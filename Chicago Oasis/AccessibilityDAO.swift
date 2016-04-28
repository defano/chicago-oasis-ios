//
//  AccessabilityDAO.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/24/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AccessibilityDAO {
 
    static let baseUrl = "http://www.chicago-oasis.org/json"
    
    static func getAccessibility(mapType: MapType, year: Int, licenseType: String!, onSuccess: (indicies: [String:Double]!) -> Void, onFailure: () -> Void) {

        let url = "\(baseUrl)/\(getMapTypePath(mapType))/\(licenseType)-\(year).json";
        
        Alamofire.request(NSURLRequest(URL: NSURL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                var indicies: [String:Double] = [:]
                
                for (_, element) in json {
                    let elementType = mapType == .Neighborhoods ? "COMMUNITY_AREA" : "TRACT"
                    let elementId = element[elementType].stringValue
                    let indexValue = element["ACCESS1"].doubleValue
                    
                    indicies[elementId] = indexValue
                }
                
                onSuccess(indicies: indicies)
            }
        }

    }
    
    private static func getMapTypePath(mapType: MapType) -> String! {
        switch mapType {
        case MapType.Neighborhoods: return "community"
        default: return "census"
        }
    }
}

class AccessibilityRecord {
    let id: String
    let accessibilityIndex: Double
    
    init (id: String, accessibilityIndex: Double) {
        self.id = id
        self.accessibilityIndex = accessibilityIndex
    }
}