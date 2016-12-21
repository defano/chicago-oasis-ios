//
//  AppDelegate.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import XCGLogger

let logger = XCGLogger()

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        let defaults = Foundation.UserDefaults.standard
        defaults.register(defaults: [UserDefaults.polygonCacheEnabledIdentifier:true])
        
        return true
    }

}

