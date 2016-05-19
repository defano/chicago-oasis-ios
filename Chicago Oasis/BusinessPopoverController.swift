//
//  BusinessPopoverController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class BusinessPopoverController : AreaPopoverController {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var body: UILabel!
 
    override func viewDidLoad() {
        if let
            businessName = super.criticalBusiness?.dbaName,
            address = super.criticalBusiness?.address,
            atRiskPop = super.criticalBusiness?.atRiskPop
        {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

            heading.text = businessName.capitalizedString
            subtitle.text = address.uppercaseString
            body.text = String(format: "If this business were to close, a population of %@ would live more than a mile away from a competing business.".localized, numberFormatter.stringFromNumber(atRiskPop)!)
        }
    }
}

//If this business were to close, a population of 236,652 would live more than a mile away from a competing business.
