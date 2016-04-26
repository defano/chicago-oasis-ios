//
//  LaunchViewController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/25/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController : UIViewController {
    
    var polygonsReady = false
    var licensesReady = false
    
    override func viewDidLoad() {

        PolygonDAO.loadPolygons
            {
                self.polygonsReady = true
                if (self.licensesReady) {
                    self.segue()
            }
        }
        
        LicenseDAO.loadLicenses(
            {
                self.licensesReady = true
                if (self.polygonsReady) {
                    self.segue()
                }
            },
            onFailure: {
                // TODO: Failed to load
            })
    }
    
    private func segue() {
        dispatch_async(dispatch_get_main_queue()){
            self.performSegueWithIdentifier("next", sender: self)
        }
    }
}