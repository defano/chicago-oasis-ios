//
//  SociographicPopoverController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/28/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class NeighborhoodPopoverController : AreaPopoverController, UITableViewDataSource {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var table: UITableView!
        
    override func viewDidLoad() {
        table.dataSource = self
        table.reloadData()
        
        if let
            areaName = super.polygon?.name,
            let selectedYear = super.selectedYear,
            let accessAlpha = super.accessibilityAlpha
        {
            let accessAdjective = accessibilityAdjectiveForAlpha(accessAlpha)
            let accessNoun = accessibilityNounForAlpha(accessAlpha)
            
            heading.text = areaName
            subtitle.text = accessAdjective.uppercased()
            bodyText.text = String(format: "In %d, the %@ community was among the neighborhoods with %@ to businesses of this type.".localized, selectedYear, areaName.capitalized, accessNoun.lowercased())
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "sociographicCell")
        
        if let
            perCapitaIncome = super.record?.perCapitaIncome,
            let percentPoverty = super.record?.percentHouseholdsBelowPoverty,
            let percent16Unemployed = super.record?.percent16Unemployed,
            let percent25Unemployed = super.record?.percent25Unemployed,
            let hardshipIndex = super.record?.hardshipIndex
        {
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell?.textLabel?.text = "Per-capita income"
                let currencyFormatter = NumberFormatter()
                currencyFormatter.numberStyle = NumberFormatter.Style.currency
                cell?.detailTextLabel?.text = currencyFormatter.string(from: NSNumber(value: perCapitaIncome))
                break
            case 1:
                cell?.textLabel?.text = "Below poverty"
                cell?.detailTextLabel?.text = percentPoverty.description + "%"
                break
            case 2:
                cell?.textLabel?.text = "Unemployed (ages 16+)"
                cell?.detailTextLabel?.text = percent16Unemployed.description + "%"
                break
            case 3:
                cell?.textLabel?.text = "Unemployed (ages 25+)"
                cell?.detailTextLabel?.text = percent25Unemployed.description + "%"
                break
            default:
                cell?.textLabel?.text = "Hardship index"
                cell?.detailTextLabel?.text = hardshipIndex.description
                break
            }
        }
        
        return cell!
    }

}
