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
            let address = super.criticalBusiness?.address,
            let atRiskPop = super.criticalBusiness?.atRiskPop
        {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal

            heading.text = businessName.capitalized
            subtitle.text = address.uppercased()
            
            body.text = String(format: "If this business were to close, a population of %@ would live more than a mile away from a competing business.".localized, numberFormatter.string(from: NSNumber(value: atRiskPop))!)
        }
    }
}
