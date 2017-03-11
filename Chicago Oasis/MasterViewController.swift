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
    var licenses: [License] = []
    var visibleLicenses: [License] = []

    // MARK: - UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.licenses = LicenseService.sharedInstance.licenses
        self.visibleLicenses = licenses
        
        searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let license = visibleLicenses[(indexPath as NSIndexPath).row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.license = license
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        visibleLicenses = []
        
        if (searchText.isEmpty) {
            visibleLicenses = licenses
        }
        
        else {
            for thisLicense in licenses {
                // Name of license matches search text
                if thisLicense.title.uppercased().contains(searchText.uppercased()) {
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

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleLicenses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let license = visibleLicenses[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = license.title
        cell.detailTextLabel!.text = "\(license.earliestYear) - \(license.latestYear)"
        
        return cell
    }

}

