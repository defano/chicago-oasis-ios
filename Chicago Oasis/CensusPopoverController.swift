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
            areaName = super.polygon?.name,
            accessAlpha = super.accessibilityAlpha,
            oneMile = super.accessibilityRecord?.oneMile,
            twoMile = super.accessibilityRecord?.twoMile,
            threeMile = super.accessibilityRecord?.threeMile
        {
            let accessAdjective = accessibilityAdjectiveForAlpha(accessAlpha)
            
            heading.text = areaName
            subtitle.text = accessAdjective.uppercaseString
            
            bodyText.text = "In \(selectedYear), \(areaName) had an average of \(oneMile) business(es) of this kind within one mile of every resident, \(twoMile) within two miles, and \(threeMile) within three miles."
        
            bodySubtext.text = "This makes \(areaName) among the \(accessAdjective.lowercaseString) census tracts in Chicago."
        }
    }
}