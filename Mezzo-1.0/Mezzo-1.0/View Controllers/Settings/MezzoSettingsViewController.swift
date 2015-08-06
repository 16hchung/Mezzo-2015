//
//  MezzoSettingsViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/30/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

class MezzoSettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("all donations", properties: ["action" : "show settings"])
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
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            println("back button tapped")
            let mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("back", properties: ["from screen": "settings home page"])
        }
    }

}

extension MezzoSettingsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("show setting", properties: ["setting type" : "about mezzo"])
    }
    
}
