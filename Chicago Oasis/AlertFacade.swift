//
//  ModalAlertFacade.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/30/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class AlertFacade {
    
    static func alertFatal (forCondition: FatalError, from: UIViewController) {
        let alert = UIAlertController(title: "Oops!".localized, message: messageForFatalError(forCondition), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Quit".localized, style: UIAlertActionStyle.Default, handler: { (action) in
            assertionFailure(messageForFatalError(forCondition))
        }))
            
        from.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func messageForFatalError(fatalError: FatalError) -> String {
        switch fatalError {
        case .CantLoadPolys:
            return "An error occured loading neighborhood and census tract boundaries. Please reinstall the app and try again.".localized
        case .CantLoadRequiredData:
            return "An error occured fetching data from the server. Check that you have a working internet connection and that the chicago-oasis.org site is accessible.".localized
        }
    }
}

enum FatalError {
    case CantLoadPolys
    case CantLoadRequiredData
}