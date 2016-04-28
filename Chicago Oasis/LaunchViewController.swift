//
//  LaunchViewController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/25/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var todoTable: UITableView!
    
    var censusReady = false
    var neighborhoodsReady = false
    var licensesReady = false
    var socioeconomicReady = false
   
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        todoTable.dataSource = self
        todoTable.reloadData()
        todoTable.separatorColor = UIColor.clearColor()
        todoTable.rowHeight = 20.0
        
        PolygonDAO.loadCensusTractBoundaries {
            self.censusReady = true
            self.segue()
        }
    
        PolygonDAO.loadNeighborhoodBoundaries {
            self.neighborhoodsReady = true
            self.segue()
        }
        
        LicenseDAO.loadLicenses(
            {
                self.licensesReady = true
                self.segue()
            },
            onFailure: {
                // TODO: Failed to load
            })
        
        SocioeconomicDAO.load(
            {
                self.socioeconomicReady = true
                self.segue()
            }) {
                // TODO: Failed to load
            }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        switch indexPath.row {
        case 2:
            cell.textLabel?.text = "Precomputing neighborhoods"
            cell.accessoryType = neighborhoodsReady ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            break;
        case 3:
            cell.textLabel?.text = "Precomputing census tracts"
            cell.accessoryType = censusReady ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            break;
        case 1:
            cell.textLabel?.text = "Getting socioeconomic data"
            cell.accessoryType = socioeconomicReady ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            break;
        default:
            cell.textLabel?.text = "Getting business licenses"
            cell.accessoryType = licensesReady ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            break;
        }

        return cell
    }

    
    private func segue() {
        todoTable.reloadData()
        
        if (censusReady && neighborhoodsReady && licensesReady && socioeconomicReady) {
            dispatch_async(dispatch_get_main_queue()){
                self.performSegueWithIdentifier("next", sender: self)
            }
        }
    }
}