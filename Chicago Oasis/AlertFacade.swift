//
//  ModalAlertFacade.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/30/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

struct AlertFacade {
    
    static func alertFatal (_ forCondition: FatalError, from: UIViewController) {
        let alert = UIAlertController(title: "Oops!".localized, message: messageForFatalError(forCondition), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Quit".localized, style: UIAlertActionStyle.default, handler: { (action) in
            assertionFailure(messageForFatalError(forCondition))
        }))
            
        from.present(alert, animated: true, completion: nil)
    }
    
    static func messageForFatalError(_ fatalError: FatalError) -> String {
        switch fatalError {
        case .cantLoadPolys:
            return "An error occured loading neighborhood and census tract boundaries. Please reinstall the app and try again.".localized
        case .cantLoadRequiredData:
            return "An error occured fetching data from the server. Check that you have a working internet connection and that the chicago-oasis.org site is accessible.".localized
        }
    }
}

enum FatalError {
    case cantLoadPolys
    case cantLoadRequiredData
}
