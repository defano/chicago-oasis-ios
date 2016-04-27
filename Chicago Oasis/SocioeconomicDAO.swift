//
//  SocioeconomicDAO.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/26/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SocioeconomicDAO {

    var data: [String:SocioeconomicRecord] = [:]
    
    static func load (onSuccess: () -> Void, onFailure: () -> Void) {
        let url = "http://www.chicago-oasis.org/json/socioeconomic.json";
        
        Alamofire.request(NSURLRequest(URL: NSURL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                for (neighborhood, element) in json {
                    print("Got \(neighborhood) and \(element)")
                }
                
                onSuccess()
            }
        }

    }
    
//    "UPTOWN": {
//    "PERCENT OF HOUSING CROWDED": 3.8,
//    "PERCENT HOUSEHOLDS BELOW POVERTY": 24,
//    "PERCENT AGED 16+ UNEMPLOYED": 8.9,
//    "PERCENT AGED 25+ WITHOUT HIGH SCHOOL DIPLOMA": 11.8,
//    "PERCENT AGED UNDER 18 OR OVER 64": 22.2,
//    "PER CAPITA INCOME": 35787,
//    "HARDSHIP INDEX": 20

    
}

class SocioeconomicRecord {
    var percentHousingCrowded: Double
    var percentHouseholdsBelowPoverty: Double
    var percent16Unemployed: Double
    var percent25Unemployed: Double
    var percentUnder18Over64: Double
    var perCapitaIncome: Int
    var hardshipIndex: Int
    
    init (percentHousingCrowded: Double, percentHouseholdsBelowPoverty: Double, percent16Unemployed: Double, percent25Unemployed: Double, percentUnder18Over64: Double, perCapitaIncome: Int, hardshipIndex: Int) {
        
        self.percentHousingCrowded = percentHousingCrowded
        self.percentHouseholdsBelowPoverty = percentHouseholdsBelowPoverty
        self.percent16Unemployed = percent16Unemployed
        self.percent25Unemployed = percent25Unemployed
        self.percentUnder18Over64 = percentUnder18Over64
        self.perCapitaIncome = perCapitaIncome
        self.hardshipIndex = hardshipIndex
    }
}