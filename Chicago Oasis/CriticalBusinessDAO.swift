//
//  CriticalBusinessDAO.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/26/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CriticalBusinessDAO {
    
    static func getCriticalBusinesses(year: Int, licenseType: String!, onSuccess: ([CriticalBusinessRecord]) -> Void, onFailure: () -> Void) {
        
        let url = "http://www.chicago-oasis.org/json/critical/critical-\(licenseType)-\(year).json";
        
        Alamofire.request(NSURLRequest(URL: NSURL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                var criticalBusinesses: [CriticalBusinessRecord] = []
                
                for (_, element) in json {
                    let lat = element["LATTITUDE"].doubleValue
                    let lng = element["LONGITUDE"].doubleValue
                    let dbaName = element["DOING_BUSINESS_AS_NAME"].stringValue
                    let atRiskPop = element["POP_AT_RISK"].intValue
                    
                    criticalBusinesses.append(CriticalBusinessRecord(lat: lat, lng: lng, dbaName: dbaName, atRiskPop: atRiskPop))
                }
                
                onSuccess(criticalBusinesses)
            }
        }
    }
}

class CriticalBusinessRecord {
    var lat: Double
    var lng: Double
    var dbaName: String
    var atRiskPop: Int

    init (lat: Double, lng: Double, dbaName: String, atRiskPop: Int) {
        self.lat = lat
        self.lng = lng
        self.dbaName = dbaName
        self.atRiskPop = atRiskPop
    }
}