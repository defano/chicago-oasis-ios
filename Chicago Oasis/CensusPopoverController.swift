//
//  CensusPopoverController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/28/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class CensusPopoverController : AreaPopoverController {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var bodySubtext: UILabel!
    
    override func viewDidLoad() {
        if let
            selectedYear = super.selectedYear,
            let areaName = super.polygon?.name,
            let accessAlpha = super.accessibilityAlpha,
            let oneMile = super.accessibilityRecord?.oneMile,
            let twoMile = super.accessibilityRecord?.twoMile,
            let threeMile = super.accessibilityRecord?.threeMile
        {
            let accessAdjective = accessibilityAdjectiveForAlpha(accessAlpha)
            
            heading.text = areaName
            subtitle.text = accessAdjective.uppercased()
            
            bodyText.text = String(format: "In %d, %@ had an average of %d business(es) of this kind within one mile of every resident, %d within two miles, and %d within three miles.".localized, selectedYear, areaName, oneMile, twoMile, threeMile)
            bodySubtext.text = String(format: "This makes %@ among the %@ census tracts in Chicago.".localized, areaName, accessAdjective.lowercased())
        }
    }
}
