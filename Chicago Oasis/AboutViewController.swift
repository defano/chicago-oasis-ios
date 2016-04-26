//
//  AboutViewController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/24/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController : UIViewController {
    
    @IBOutlet weak var web: UIWebView!
    
    override func viewDidLoad() {
        web.backgroundColor = UIColor.clearColor()
        web.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.chicago-oasis.org/about.md")!))
    }
}