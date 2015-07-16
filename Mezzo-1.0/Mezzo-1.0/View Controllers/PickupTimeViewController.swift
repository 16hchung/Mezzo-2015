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

        // Do any additional setup after loading the view.
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
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}