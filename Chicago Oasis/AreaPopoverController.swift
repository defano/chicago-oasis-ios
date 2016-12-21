//
//  AreaPopoverController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/28/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class AreaPopoverController : UIViewController {
    
    var polygon: Polygon?
    var record: SocioeconomicRecord?
    var accessibilityRecord: AccessibilityRecord?
    var criticalBusiness: CriticalBusiness?
    var accessibilityAlpha: Double?
    var selectedYear: Int?
    
    func accessibilityAdjectiveForAlpha (_ alpha: Double) -> String {
        if (alpha >= 0.0 && alpha < 0.2) {
            return "most deserted".localized
        } else if (alpha >= 0.2 && alpha < 0.4) {
            return "largely deserted".localized
        } else if (alpha >= 0.4 && alpha < 0.6) {
            return "somewhat accessible".localized
        } else if (alpha >= 0.6 && alpha < 0.8) {
            return "largely accessible".localized
        } else {
            return "most accessible".localized
        }
    }
    
    func accessibilityNounForAlpha (_ alpha: Double) -> String {
        if (alpha >= 0 && alpha < 0.2) {
            return "very poor access".localized
        } else if (alpha >= 0.2 && alpha < 0.4) {
            return "poor access".localized
        } else if (alpha >= 0.4 && alpha < 0.6) {
            return "average access".localized
        } else if (alpha >= 0.6 && alpha < 0.8) {
            return "good access".localized
        } else {
            return "best access".localized
        }
    }
}
