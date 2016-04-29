//
//  SocioeconomicRecord.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation

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