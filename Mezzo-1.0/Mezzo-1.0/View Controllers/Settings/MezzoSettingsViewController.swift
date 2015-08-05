//
//  MezzoSettingsViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/30/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class MezzoSettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Save Weekly Hours":
                let source = segue.sourceViewController as! WeeklyHoursViewController
                source.saveAllDateSettings()
            case "Save Food Policies":
                println("saving food policies")
            default:
                break
            }
        }
    }
    
    @IBAction func unwindFromMyInfo(sender: UIStoryboardSegue) {
        switch sender.identifier! {
        case "Save my info":
            println("saving my info")
        default:
            break
        }
    }
    

}
