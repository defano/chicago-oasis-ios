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
   
    // MARK: - UIVIewController
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoTable.dataSource = self
        todoTable.reloadData()
        todoTable.separatorColor = UIColor.clear
        todoTable.backgroundColor = UIColor.clear // Fix for some iPad models that override the UI builder values. Doh!
        todoTable.rowHeight = 20.0
    }
    
    override func viewDidAppear(_ animated: Bool)  {
        super.viewDidAppear(animated)
        
        LicenseService.sharedInstance.loadLicenses(
            {
                self.licensesReady = true
                self.segue()
            },
            onFailure: {
                AlertFacade.alertFatal(FatalError.cantLoadRequiredData, from: self)
            })
        
        SocioeconomicService.sharedInstance.load(
            {
                self.socioeconomicReady = true
                self.segue()
            }) {
                AlertFacade.alertFatal(FatalError.cantLoadRequiredData, from: self)
            }
        
        PolygonService.sharedInstance.loadCensusTractBoundaries {
            self.censusReady = true
            self.segue()
        }
        
        PolygonService.sharedInstance.loadNeighborhoodBoundaries {
            self.neighborhoodsReady = true
            self.segue()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear  // Fix for some iPad models that override the UI builder values. Doh!
        
        switch (indexPath as NSIndexPath).row {
        case 2:
            cell.textLabel?.text = "Precomputing neighborhoods".localized
            cell.accessoryType = neighborhoodsReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        case 3:
            cell.textLabel?.text = "Precomputing census tracts".localized
            cell.accessoryType = censusReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        case 1:
            cell.textLabel?.text = "Getting socioeconomic data".localized
            cell.accessoryType = socioeconomicReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        default:
            cell.textLabel?.text = "Getting business licenses".localized
            cell.accessoryType = licensesReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        }

        return cell
    }

    // MARK: - Segue
    
    private func segue() {
        todoTable.reloadData()
        
        if (censusReady && neighborhoodsReady && licensesReady && socioeconomicReady) {
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "next", sender: self)
            }
        }
    }
}
