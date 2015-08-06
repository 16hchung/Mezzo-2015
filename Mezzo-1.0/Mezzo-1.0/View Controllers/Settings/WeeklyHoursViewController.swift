//
//  FoodPreferencesViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/30/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import Mixpanel

class WeeklyHoursViewController: UIViewController {

    // MARK: Outlets and Properties
    
    weak var selectedDayButton: UIButton!
    @IBOutlet var weekdayButtons: [UIButton]!
    
    @IBOutlet weak var unavailableOptionButton: UIButton!
    @IBOutlet weak var availableOptionButton: UIButton!
    
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    
    @IBOutlet weak var timePickingContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var weeklyHours: [String : (start: NSDate?, end: NSDate?)] = [:]

    // MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            orgUser.fetchIfNeededInBackgroundWithBlock { result, error -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.loadAllDateSettings()
                    
                    self.selectedDayButton = self.weekdayButtons.filter { $0.titleLabel!.text == "M" }[0]
                    self.toggleDayButton(self.selectedDayButton, select: true)
                    self.showSettingsForDay(self.selectedDayButton)
                }
            }
        }
        
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("show setting", properties: ["setting type" : "weekly hours"])
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    // MARK: UI change methods
    
    /// load strings from parse into local weeklyHours property + toggle unavailable day buttons
    func loadAllDateSettings() {
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            weeklyHours = TimeHelper.datesDictionaryFromStrings(orgUser.weeklyHours)
            
            for key in TimeHelper.weekDaySymbols {
                let dateTuple = weeklyHours[key]!
                
                // set gray background for all unavailable days
                let dayButton = weekdayButtons.filter { $0.titleLabel!.text! == key }
                let available = dateTuple.start != nil && dateTuple.end != nil
                toggleAvailabilityForDayButton(dayButton[0], available: available)
            }
        }
    }
    
    func saveAllDateSettings() {
        saveDateSettingsForDay(selectedDayButton)

        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            orgUser.weeklyHours = TimeHelper.stringsFromDatesDictionary(weeklyHours)
            
            orgUser.saveInBackground()
        }
    }

    @IBAction func weekDayButtonTapped(sender: UIButton) {
        // save current day's settings
        saveDateSettingsForDay(selectedDayButton)
        
        // set former day button to deselected
        toggleDayButton(selectedDayButton, select: false)
        
        // select new day button
        toggleDayButton(sender, select: true)
        selectedDayButton = sender
        
        // change availability checkboxes
        availableOptionButton.setTitle("I am available on \(fullDayStringForButton(sender))...", forState: UIControlState.Normal)
        unavailableOptionButton.setTitle("I'm not available at all on \(fullDayStringForButton(sender)).", forState: UIControlState.Normal)
        
        showSettingsForDay(selectedDayButton)
    }
    
    @IBAction func availabilityToggled(sender: UIButton) {
        let available = sender == availableOptionButton
        toggleAvailabilityForDayButton(selectedDayButton, available: available)
        availableOptionButton.selected = available
        unavailableOptionButton.selected = !available
        timePickingContentView.hidden = !available
        if available { scrollView.flashScrollIndicators() }
        
        let dateTuple = weeklyHours[selectedDayButton.titleLabel!.text!]
        if available && dateTuple!.start == nil { resetDatePickersToDefaults() }
    }
    
    /// toggle selection of day button (border)
    func toggleDayButton(button: UIButton, select: Bool) {
        button.layer.borderWidth = select ? 3.0 : 0.0
        button.layer.borderColor = UIColor(red: 0, green: 84.0/255.0, blue: 180.0/255.0, alpha: 1.0).CGColor // dark blue
//        button.layer.borderColor = UIColor(red: 192.0/255.0, green: 54.0/255.0, blue: 44.0/255.0, alpha: 1.0).CGColor // golden gate bridge
        
        if select {
            button.setTitleColor(UIColor(red: 0, green: 84.0/255.0, blue: 180.0/255.0, alpha: 1.0), forState: UIControlState.Normal) // dark blue
//            button.setTitleColor(UIColor(red: 192.0/255.0, green: 54.0/255.0, blue: 44.0/255.0, alpha: 1.0), forState: UIControlState.Normal) // golden gate bridge
        } else {
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    
    /// toggle availability indicator (background color)
    func toggleAvailabilityForDayButton(button: UIButton, available: Bool) {
        if available {
            button.backgroundColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        } else {
            button.backgroundColor = UIColor.lightGrayColor()
        }
    }

    /// set availability checkmarks + toggle enabled of datepickers
    func showSettingsForDay(button: UIButton!) {
        let datesTuple = weeklyHours[button.titleLabel!.text!]
        if let startDate = datesTuple?.start, endDate = datesTuple?.end {
            
            fromTimePicker.date = startDate
            toTimePicker.date = endDate
            
            toTimePicker.minimumDate = fromTimePicker.date
            fromTimePicker.maximumDate = toTimePicker.date
            
            availabilityToggled(availableOptionButton)
            
        } else {
            availabilityToggled(unavailableOptionButton)
        }
    }
    
    func fullDayStringForButton(button: UIButton) -> String {
        switch button.titleLabel!.text! {
        case "S":
            return "Sundays"
        case "M":
            return "Mondays"
        case "T":
            return "Tuesdays"
        case "W":
            return "Wednesdays"
        case "Th":
            return "Thursdays"
        case "F":
            return "Fridays"
        case "Sa":
            return "Saturdays"
        default:
            return ""
        }
    }
    
    func resetDatePickersToDefaults() {
        fromTimePicker.date = Organization.DefaultHours.startTime
        toTimePicker.date = Organization.DefaultHours.endTime
    }
    
    func saveDateSettingsForDay(button: UIButton) {
        if availableOptionButton.selected {
            weeklyHours.updateValue((fromTimePicker.date, toTimePicker.date), forKey: button.titleLabel!.text!)
        } else {
            weeklyHours.updateValue((nil, nil), forKey: button.titleLabel!.text!)
        }
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
