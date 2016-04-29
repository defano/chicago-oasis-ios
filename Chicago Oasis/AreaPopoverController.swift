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
    
    var record: SocioeconomicRecord?
    var accessibilityRecord: AccessibilityRecord?
    var accessibilityAlpha: Double?
    var areaName: String?
    var selectedYear: Int?
    
    func accessibilityAdjectiveForAlpha (alpha: Double?) -> String {
        if (alpha >= 0 && alpha < 0.2) {
            return "most deserted"
        } else if (alpha >= 0.2 && alpha < 0.4) {
            return "largely deserted"
        } else if (alpha >= 0.4 && alpha < 0.6) {
            return "somewhat accessible"
        } else if (alpha >= 0.6 && alpha < 0.8) {
            return "largely accessible"
        } else {
            return "most accessible"
        }
    }
    
    func accessibilityNounForAlpha (alpha: Double?) -> String {
        if (alpha >= 0 && alpha < 0.2) {
            return "lowest levels of access"
        } else if (alpha >= 0.2 && alpha < 0.4) {
            return "poor access"
        } else if (alpha >= 0.4 && alpha < 0.6) {
            return "average access"
        } else if (alpha >= 0.6 && alpha < 0.8) {
            return "good access"
        } else {
            return "best access"
        }
    }
}