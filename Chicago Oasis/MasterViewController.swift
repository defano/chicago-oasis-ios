//
//  MasterViewController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var detailViewController: DetailViewController?
    var licenses: [LicenseRecord] = []
    var visibleLicenses: [LicenseRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.licenses = LicenseDAO.licenses
        self.visibleLicenses = licenses
        
        searchBar.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let license = licenses[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.license = license
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Search Bar
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        visibleLicenses = []
        
        if (searchText.isEmpty) {
            visibleLicenses = licenses
        }
        
        else {
            for thisLicense in licenses {
                
                // Name of license matches search text
                if thisLicense.title.uppercaseString.containsString(searchText.uppercaseString) {
                    visibleLicenses.append(thisLicense)
                }
                    
                    // Search text is an integer; see if its within the range of available years
                else if let searchYear = Int(searchText) {
                    if searchYear >= thisLicense.earliestYear && searchYear <= thisLicense.latestYear {
                        visibleLicenses.append(thisLicense)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleLicenses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let license = visibleLicenses[indexPath.row]
        cell.textLabel!.text = license.title
        cell.detailTextLabel!.text = "\(license.earliestYear) - \(license.latestYear)"
        
        return cell
    }

}

