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
 
    static func getAccessibility(mapType: MapType, year: Int, licenseType: String!, onSuccess: (indicies: [String:AccessibilityRecord]!) -> Void, onFailure: () -> Void) {

        let url = "http://www.chicago-oasis.org/json/\(getMapTypePath(mapType))/\(licenseType)-\(year).json";
        
        Alamofire.request(NSURLRequest(URL: NSURL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                var records: [String:AccessibilityRecord] = [:]
                
                for (_, element) in json {
                    let areaType = mapType == .Neighborhoods ? "COMMUNITY_AREA" : "TRACT"
                    let areaId = element[areaType].stringValue
                    
                    let record = AccessibilityRecord(id: areaId, index: element["ACCESS1"].doubleValue)
                    
                    // Optional values (present only on census records)
                    record.oneMile = element["ONE_MILE"].intValue
                    record.twoMile = element["TWO_MILE"].intValue
                    record.threeMile = element["THREE_MILE"].intValue
                    
                    records[areaId] = record
                }
                
                onSuccess(indicies: records)
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