//
//  PickupTimeViewController.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/15/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

class PickupTimeViewController: UIViewController {
    
    @IBOutlet weak var deadlineTimePicker: UIDatePicker!
//    @IBOutlet weak var endTimeRangePicker: UIDatePicker!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var donation: Donation!
    
    // mixpanel setup
    let MIXPANEL_NEW_DONATION_EVENT = "new donation changed"
    let MIXPANEL_ACTION = "action"
    let MIXPANEL_VALUE = "value"
    let mixpanel = Mixpanel.sharedInstance()

    // MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startTime = nearestFifteenthMinute()
        deadlineTimePicker.minimumDate = startTime
//        startTimePicked(startTimeRangePicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: methods
    
    func saveDonation() {
        donation.donorTimeRangeEnd = deadlineTimePicker.date
//        donation.donorTimeRangeEnd = endTimeRangePicker.date
    }
    
    @IBAction func startTimePicked(sender: AnyObject) {
//        let startTime = NSDate(timeInterval: 10800, sinceDate: startTimeRangePicker.date)
//        // 10800 seconds in 3 hours
//        endTimeRangePicker.minimumDate = startTime
//        endTimeRangePicker.setDate(startTime, animated: true)
        
        mixpanel.track(MIXPANEL_NEW_DONATION_EVENT,
            properties: [MIXPANEL_ACTION: "start time picked", MIXPANEL_VALUE: "N/A"])
    }
//    
//    @IBAction func endTimePicked(sender: AnyObject) {
//        mixpanel.track(MIXPANEL_NEW_DONATION_EVENT,
//            properties: [MIXPANEL_ACTION: "end time picked", MIXPANEL_VALUE: "N/A"])
//    }
    
    private func nearestFifteenthMinute() -> NSDate {
        var componentMask : NSCalendarUnit = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute)
        var components = NSCalendar.currentCalendar().components(componentMask, fromDate: NSDate())
        
        components.minute += 15 - components.minute % 15
        components.second = 0
        if (components.minute == 0) {
            components.hour += 1
        }
        
        return NSCalendar.currentCalendar().dateFromComponents(components)!
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
                
                mixpanel.track("next", properties: ["from screen": "new donation when", "action": "next"])
            default:
                break
            }
        }
    }
}