//
//  SplitViewController.swift
//  Weather App
//
//  Created by Tom Davis on 22/01/2017.
//  Copyright © 2017 Tom Davis. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    
    @IBOutlet weak var locationsItem: NSSplitViewItem!
    @IBOutlet weak var detailsItem: NSSplitViewItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let locationsVC = locationsItem.viewController as? LocationViewController {
            if let detailsVC = detailsItem.viewController as? DetailViewController {
                locationsVC.detailsVC = detailsVC
                detailsVC.locationsVC = locationsVC
            }
        }
    }
}
