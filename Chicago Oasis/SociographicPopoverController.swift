//
//  SociographicPopoverController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/28/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class SociographicPopoverController : UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var communityArea: UILabel!
    @IBOutlet weak var accessibilityLevel: UILabel!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var table: UITableView!
    
    var record: SocioeconomicRecord?
    var accessibilityAlpha: Double?
    var areaName: String?
    var selectedYear: Int?
    
    override func viewDidAppear(animated: Bool) {
        table.dataSource = self
        table.reloadData()
        
        communityArea.text = areaName
        accessibilityLevel.text = accessibilityAdjectiveForAlpha(accessibilityAlpha)
        bodyText.text = "In \(selectedYear!), the \(areaName!.capitalizedString) community was among the neighborhoods with the \(accessibilityNounForAlpha(accessibilityAlpha).lowercaseString) to businesses of this type."
    }
    
    func accessibilityAdjectiveForAlpha (alpha: Double?) -> String {
        if (alpha >= 0 && alpha < 0.2) {
            return "MOST DESERTED"
        } else if (alpha >= 0.2 && alpha < 0.4) {
            return "LARGELY DESERTED"
        } else if (alpha >= 0.4 && alpha < 0.6) {
            return "SOMEWHAT ACCESSIBLE"
        } else if (alpha >= 0.6 && alpha < 0.8) {
            return "LARGELY ACCESSIBLE"
        } else {
            return "MOST ACCESSIBLE"
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("sociographicCell")
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Per-capita income"
            let currencyFormatter = NSNumberFormatter()
            currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            cell?.detailTextLabel?.text = currencyFormatter.stringFromNumber((record?.perCapitaIncome)!)
            break
        case 1:
            cell?.textLabel?.text = "Below poverty"
            cell?.detailTextLabel?.text = (record?.percentHouseholdsBelowPoverty.description)! + "%"
            break
        case 2:
            cell?.textLabel?.text = "Unemployed (ages 16+)"
            cell?.detailTextLabel?.text = (record?.percent16Unemployed.description)! + "%"
            break
        case 3:
            cell?.textLabel?.text = "Unemployed (ages 25+)"
            cell?.detailTextLabel?.text = (record?.percent25Unemployed.description)! + "%"
            break
        default:
            cell?.textLabel?.text = "Hardship index"
            cell?.detailTextLabel?.text = record?.hardshipIndex.description
            break
        }
        
        return cell!
    }

}