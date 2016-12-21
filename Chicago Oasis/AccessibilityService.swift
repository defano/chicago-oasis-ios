//
//  AccessabilityService.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/24/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AccessibilityService {
 
    static let sharedInstance = AccessibilityService()
    private init() {}
    
    func getAccessibility(_ mapType: MapType, year: Int, licenseType: String, onSuccess: @escaping (_ indicies: [String:AccessibilityRecord]?) -> Void, onFailure: @escaping () -> Void) {

        let url = "http://www.chicago-oasis.org/json/\(self.getMapTypePath(mapType))/\(licenseType)-\(year).json";
        
        Alamofire.request(URLRequest(url: URL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                var records: [String:AccessibilityRecord] = [:]
                
                for (_, element) in json {
                    let areaType = mapType == .neighborhoods ? "COMMUNITY_AREA" : "TRACT"
                    let areaId = element[areaType].stringValue
                    
                    let record = AccessibilityRecord(
                        id: areaId,
                        index: element["ACCESS1"].doubleValue,
                        oneMile: element["ONE_MILE"].intValue,
                        twoMile: element["TWO_MILE"].intValue,
                        threeMile: element["THREE_MILE"].intValue
                    )
                    
                    records[areaId] = record
                }
                
                onSuccess(records)
            }
        }

    }
    
    private func getMapTypePath(_ mapType: MapType) -> String {
        switch mapType {
        case MapType.neighborhoods: return "community"
        default: return "census"
        }
    }
}

struct AccessibilityRecord {
    let id: String
    let index: Double
    let oneMile, twoMile, threeMile: Int?
    
    init (id: String, index: Double, oneMile: Int?, twoMile: Int?, threeMile: Int?) {
        self.id = id
        self.index = index
        self.oneMile = oneMile;
        self.twoMile = twoMile;
        self.threeMile = threeMile;
    }
}
