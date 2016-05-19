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
            selectedYear = super.selectedYear,
            accessAlpha = super.accessibilityAlpha
        {
            let accessAdjective = accessibilityAdjectiveForAlpha(accessAlpha)
            let accessNoun = accessibilityNounForAlpha(accessAlpha)
            
            heading.text = areaName
            subtitle.text = accessAdjective.uppercaseString
            bodyText.text = String(format: "In %d, the %@ community was among the neighborhoods with %@ to businesses of this type.".localized, selectedYear, areaName.capitalizedString, accessNoun.lowercaseString)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("sociographicCell")
        
        if let
            perCapitaIncome = super.record?.perCapitaIncome,
            percentPoverty = super.record?.percentHouseholdsBelowPoverty,
            percent16Unemployed = super.record?.percent16Unemployed,
            percent25Unemployed = super.record?.percent25Unemployed,
            hardshipIndex = super.record?.hardshipIndex
        {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "Per-capita income"
                let currencyFormatter = NSNumberFormatter()
                currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                cell?.detailTextLabel?.text = currencyFormatter.stringFromNumber(perCapitaIncome)
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