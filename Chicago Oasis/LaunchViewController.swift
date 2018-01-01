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
                self.onWorkItemCompleted()
            },
            onFailure: {
                AlertFacade.alertFatal(FatalError.CantLoadRequiredData, from: self)
            })
        
        SocioeconomicService.sharedInstance.load(
            {
                self.socioeconomicReady = true
                self.onWorkItemCompleted()
            }) {
                AlertFacade.alertFatal(FatalError.CantLoadRequiredData, from: self)
            }
        
        PolygonService.sharedInstance.loadCensusTractBoundaries {
            self.censusReady = true
            self.onWorkItemCompleted()
        }
        
        PolygonService.sharedInstance.loadNeighborhoodBoundaries {
            self.neighborhoodsReady = true
            self.onWorkItemCompleted()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WorkItems.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear  // Fix for some iPad models that override the UI builder values. Doh!
        
        switch (indexPath as NSIndexPath).row {
        case WorkItems.PrecomputingNeighborhoods.rawValue:
            cell.textLabel?.text = "Precomputing neighborhoods".localized
            cell.accessoryType = neighborhoodsReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        case WorkItems.PrecomputingCensusTracts.rawValue:
            cell.textLabel?.text = "Precomputing census tracts".localized
            cell.accessoryType = censusReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        case WorkItems.FetchingSocioeconomicData.rawValue:
            cell.textLabel?.text = "Getting socioeconomic data".localized
            cell.accessoryType = socioeconomicReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
        case WorkItems.FetchingBusinessLicenses.rawValue:
            cell.textLabel?.text = "Getting business licenses".localized
            cell.accessoryType = licensesReady ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            break;
            
        default:
            assertionFailure("Bug! Implemented work item for row.")
        }

        return cell
    }

    // MARK: - Segue
    
    private func onWorkItemCompleted() {
        todoTable.reloadData()
        
        if (censusReady && neighborhoodsReady && licensesReady && socioeconomicReady) {
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "next", sender: self)
            }
        }
    }
  
    private enum WorkItems: Int {
        case FetchingBusinessLicenses = 0
        case FetchingSocioeconomicData
        case PrecomputingNeighborhoods
        case PrecomputingCensusTracts
        
        static let allValues = [FetchingBusinessLicenses, FetchingSocioeconomicData, PrecomputingNeighborhoods, PrecomputingCensusTracts]
    }
}
