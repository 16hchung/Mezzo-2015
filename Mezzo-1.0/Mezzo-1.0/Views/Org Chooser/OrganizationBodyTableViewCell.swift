//
//  OrganizationBodyTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class OrganizationBodyTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var unacceptableFoodLabel: UILabel!
    @IBOutlet weak var seeWebsiteButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    // MARK: Properties
    
    var donorSpecifiedTimeRange: (start: NSDate, end: NSDate)!
    
    weak var organization: Organization? {
        didSet {
            if let organization = organization {
                setAvailabilityLabel()
                
                setUnacceptableFoodsLabel()
                
                setWarningLabel()
            }
        }
    }
    
    func setAvailabilityLabel() {
//        let relevantHours = TimeHelper.relevantHoursInTimeRange(donorSpecifiedTimeRange, forOrgSchedule: organization!.weeklyHours)
//        hoursLabel.numberOfLines = relevantHours.count
//        hoursLabel.text = "\n".join(relevantHours)
        var displayable = [String]()
        for index in 0...6 {
            let weekday = TimeHelper.weekdayFullNames[index]
            let hours = (organization!.weeklyHours[index] == " - ") ? " --" : organization!.weeklyHours[index]
            displayable.append("\(weekday): \(hours)")
        }
        hoursLabel.numberOfLines = 7
        hoursLabel.text = "\n".join(displayable)
    }
    
    func setUnacceptableFoodsLabel() {
        unacceptableFoodLabel.text = organization!.unacceptableFoods
    }
    
    func setWarningLabel() {
//        let timeRangesMatch = true
//        if timeRangesMatch {
//            warningLabel.hidden = false
//        } else {
//            warningLabel.hidden = true
//        }
    }

    
}