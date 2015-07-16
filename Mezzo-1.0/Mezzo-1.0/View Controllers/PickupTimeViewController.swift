//
//  PickupTimeViewController.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/15/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class PickupTimeViewController: UIViewController {
    
    @IBOutlet weak var startTimeRangePicker: UIDatePicker!
    @IBOutlet weak var endTimeRangePicker: UIDatePicker!
    
    var donation: Donation!

    // MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimeRangePicker.minimumDate = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: methods
    
    func saveDonation() {
        donation.donorTimeRangeStart = startTimeRangePicker.date
        donation.donorTimeRangeEnd = endTimeRangePicker.date
    }
    
    @IBAction func startTimePicked(sender: AnyObject) {
        let startTime = startTimeRangePicker.date
        endTimeRangePicker.minimumDate = startTime
        endTimeRangePicker.setDate(startTime, animated: true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch (identifier) {
            case "Choose Org":
                saveDonation()
                let destination = segue.destinationViewController as? OrganizationChooserViewController
                destination?.donation = self.donation
            default:
                break
            }
        }
    }
    
}