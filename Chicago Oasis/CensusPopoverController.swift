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
    
    @IBOutlet weak var communityArea: UILabel!
    @IBOutlet weak var accessibilityLevel: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var bodySubtext: UILabel!
    
    override func viewDidLoad() {
        communityArea.text = areaName
        accessibilityLevel.text = accessibilityAdjectiveForAlpha(accessibilityAlpha).uppercaseString
        
        bodyText.text = "In \(selectedYear!), \(areaName!) had an average of \(accessibilityRecord!.oneMile!) business(es) of this kind within on mile of every resident, \(accessibilityRecord!.twoMile!) within two miles, and \(accessibilityRecord!.threeMile!) within three miles."
        
        bodySubtext.text = "This makes \(areaName!) among the \(accessibilityAdjectiveForAlpha(super.accessibilityAlpha).lowercaseString) census tracts in Chicago."
    }
}