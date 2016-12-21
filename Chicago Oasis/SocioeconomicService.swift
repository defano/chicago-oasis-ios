//
//  SocioeconomicService.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/26/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SocioeconomicService {

    static let sharedInstance = SocioeconomicService()
    private init() {}
    
    var data: [String:SocioeconomicRecord] = [:]
    
    func load (_ onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        let url = "http://www.chicago-oasis.org/json/socioeconomic.json";
        
        Alamofire.request(URLRequest(url: URL(string: url)!)).responseJSON { response in
            guard response.result.error == nil else {
                return onFailure()
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                for (neighborhood, element) in json {
                    self.data[neighborhood] = SocioeconomicRecord(
                        percentHousingCrowded: element["PERCENT OF HOUSING CROWDED"].doubleValue,
                        percentHouseholdsBelowPoverty: element["PERCENT HOUSEHOLDS BELOW POVERTY"].doubleValue,
                        percent16Unemployed: element["PERCENT AGED 16+ UNEMPLOYED"].doubleValue,
                        percent25Unemployed: element["PERCENT AGED 25+ WITHOUT HIGH SCHOOL DIPLOMA"].doubleValue,
                        percentUnder18Over64: element["PERCENT AGED UNDER 18 OR OVER 64"].doubleValue,
                        perCapitaIncome: element["PER CAPITA INCOME"].intValue,
                        hardshipIndex: element["HARDSHIP INDEX"].intValue)
                }
                
                onSuccess()
            }
        }
    }
}

struct SocioeconomicRecord {
    let percentHousingCrowded: Double
    let percentHouseholdsBelowPoverty: Double
    let percent16Unemployed: Double
    let percent25Unemployed: Double
    let percentUnder18Over64: Double
    let perCapitaIncome: Int
    let hardshipIndex: Int
    
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
