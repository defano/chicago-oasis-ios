//
//  CriticalBusinessService.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/26/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CriticalBusinessService {
    
    static let sharedInstance = CriticalBusinessService()
    private init() {}
    
    func getCriticalBusinesses(_ year: Int, licenseType: String, onSuccess: @escaping ([CriticalBusiness]) -> Void, onFailure: @escaping () -> Void) {
        
        let url = "http://www.chicago-oasis.org/json/critical/critical-\(licenseType)-\(year).json";
        
        Alamofire.request(URLRequest(url: URL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                var criticalBusinesses: [CriticalBusiness] = []
                
                for (_, element) in json {
                    let lat = element["LATTITUDE"].doubleValue
                    let lng = element["LONGITUDE"].doubleValue
                    let dbaName = element["DOING_BUSINESS_AS_NAME"].stringValue
                    let atRiskPop = element["POP_AT_RISK"].intValue
                    let address = element["ADDRESS"].stringValue
                    
                    criticalBusinesses.append(CriticalBusiness(lat: lat, lng: lng, address: address, dbaName: dbaName, atRiskPop: atRiskPop))
                }
                
                onSuccess(criticalBusinesses)
            }
        }
    }
}

struct CriticalBusiness {
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
