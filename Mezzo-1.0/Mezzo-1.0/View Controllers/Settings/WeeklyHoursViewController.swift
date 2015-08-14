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
    
    var fromTimePicker: UIDatePicker!
    var toTimePicker: UIDatePicker!
    
    var fromMax: NSDate!
    var fromDate: NSDate! {
        didSet {
            fromTimePicker.date = fromDate
            (timePickerCells[0][0] as! DatePickerCell).date = fromDate
        }
    }
    var toMin: NSDate! {
        didSet {
            let cell = timePickerCells[1][0] as! DatePickerCell
            toTimePicker.minimumDate = toMin
            if cell.date < toMin { cell.date = toMin }
        }
    }
    var toDate: NSDate! {
        didSet {
            toTimePicker.date = toDate
            (timePickerCells[1][0] as! DatePickerCell).date = toDate
        }
    }
    
    @IBOutlet weak var timeTableView: UITableView!
    var timePickerCells: NSArray = []
    
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
        
        // set up time picker table view cells
        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.rowHeight = UITableViewAutomaticDimension
        timeTableView.estimatedRowHeight = 44
        
        // add insets to un/available buttons
        availableOptionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        unavailableOptionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        unavailableOptionButton.titleLabel?.numberOfLines = 1
        unavailableOptionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // date picker cells
        let fromTimePickerCell = DatePickerCell(style: .Default, reuseIdentifier: "From")
        fromTimePickerCell.datePicker.addTarget(self, action: "timeChanged:", forControlEvents: .ValueChanged)
        fromTimePicker = fromTimePickerCell.datePicker
        let toTimePickerCell = DatePickerCell(style: .Default, reuseIdentifier: "To")
        toTimePickerCell.datePicker.addTarget(self, action: "timeChanged:", forControlEvents: .ValueChanged)
        toTimePicker = toTimePickerCell.datePicker
        timePickerCells = [[fromTimePickerCell], [toTimePickerCell]]
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
        
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("next", properties: ["screen" : "weekly hours", "action" : "save"])
    }

    @IBAction func weekDayButtonTapped(sender: UIButton) {
        
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("edit setting", properties: ["field" : "weekday", "value" : sender.titleLabel!.text!])
        
        // save current day's settings
        saveDateSettingsForDay(selectedDayButton)
        
        // set former day button to deselected
        toggleDayButton(selectedDayButton, select: false)
        
        // select new day button
        toggleDayButton(sender, select: true)
        selectedDayButton = sender
        
        // change availability checkboxes
        availableOptionButton.setTitle("I'm available on \(fullDayStringForButton(sender))...", forState: UIControlState.Normal)
        unavailableOptionButton.setTitle("I'm not available at all on \(fullDayStringForButton(sender))", forState: UIControlState.Normal)
        
        showSettingsForDay(selectedDayButton)
    }
    
    @IBAction func availabilityToggled(sender: UIButton) {
        availabilitySet(sender)
        
        let available = (sender == unavailableOptionButton) ? "to available" : "to unavailable"
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("edit setting", properties: ["field" : "availability", "value" : available])
    }
    
    func timeChanged(sender: UIDatePicker) {
        let mixpanel = Mixpanel.sharedInstance()
        
        switch sender {
        case fromTimePicker:
            let startTime = NSDate(timeInterval: 3600, sinceDate: fromTimePicker.date)
            // 3600 seconds in 1 hour
            toMin = startTime
            
            mixpanel.track("edit setting", properties: ["field" : "from time changed", "value" : "N/A"])
        case toTimePicker:
            let endTime = NSDate(timeInterval: -3600, sinceDate: toTimePicker.date)
            fromMax = endTime
            
            mixpanel.track("edit setting", properties: ["field" : "to time changed", "value" : "N/A"])
        default:
            break
        }
    }
    
    func availabilitySet(button: UIButton) {
        let available = button == availableOptionButton
        toggleAvailabilityForDayButton(selectedDayButton, available: available)
        availableOptionButton.selected = available
        unavailableOptionButton.selected = !available
//        timePickingContentView.hidden = !available
//        if available { scrollView.flashScrollIndicators() }
        timeTableView.hidden = !available
        
        let dateTuple = weeklyHours[selectedDayButton.titleLabel!.text!]
        if available && dateTuple!.start == nil { resetDatePickersToDefaults() }
    }
    
    /// toggle selection of day button (border)
    func toggleDayButton(button: UIButton, select: Bool) {
        button.layer.borderWidth = select ? 3.0 : 0.0
        button.layer.borderColor = UIHelper.Colors.acceptedGreen.CGColor
//        button.layer.borderColor = UIColor(red: 0, green: 84.0/255.0, blue: 180.0/255.0, alpha: 1.0).CGColor // dark blue
//        button.layer.borderColor = UIColor(red: 192.0/255.0, green: 54.0/255.0, blue: 44.0/255.0, alpha: 1.0).CGColor // golden gate bridge
        
        if select {
//            button.setTitleColor(UIColor(red: 0, green: 84.0/255.0, blue: 180.0/255.0, alpha: 1.0), forState: UIControlState.Normal) // dark blue
//            button.setTitleColor(UIColor(red: 192.0/255.0, green: 54.0/255.0, blue: 44.0/255.0, alpha: 1.0), forState: UIControlState.Normal) // golden gate bridge
        } else {
//            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    
    /// toggle availability indicator (background color)
    func toggleAvailabilityForDayButton(button: UIButton, available: Bool) {
        if available {
//            button.backgroundColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0, alpha: 1.0)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        } else {
//            button.backgroundColor = UIColor.lightGrayColor()
//            207, 0, 15
            button.setTitleColor(UIHelper.Colors.declinedMutedRed, forState: UIControlState.Normal)
        }
    }

    /// set availability checkmarks + toggle enabled of datepickers
    func showSettingsForDay(button: UIButton!) {
        let datesTuple = weeklyHours[button.titleLabel!.text!]
        if let startDate = datesTuple?.start, endDate = datesTuple?.end {
            
            fromDate = startDate
            toDate = endDate
            
            toMin = fromTimePicker.date
            fromMax = toTimePicker.date
            
            availabilitySet(availableOptionButton)
            
        } else {
            availabilitySet(unavailableOptionButton)
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
        fromDate = Organization.DefaultHours.startTime
        toDate = Organization.DefaultHours.endTime
    }
    
    func saveDateSettingsForDay(button: UIButton) {
        if availableOptionButton.selected {
            weeklyHours.updateValue((fromTimePicker.date, toTimePicker.date), forKey: button.titleLabel!.text!)
        } else {
            weeklyHours.updateValue((nil, nil), forKey: button.titleLabel!.text!)
        }
    }
}

extension WeeklyHoursViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return timePickerCells.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timePickerCells[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return timePickerCells[indexPath.section][indexPath.row] as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = timeTableView.cellForRowAtIndexPath(indexPath)
        if let timePickerCell = cell as? DatePickerCell {
            timePickerCell.selectedInTableView(tableView)
//            println("\(timePickerCell.reuseIdentifier) : \(timePickerCell.expanded)")
            timeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = timeTableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell as? DatePickerCell {
            return cell.datePickerHeight()
        }
        
        return 44
    }
}