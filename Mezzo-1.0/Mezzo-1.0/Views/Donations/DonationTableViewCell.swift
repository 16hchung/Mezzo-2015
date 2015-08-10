//
//  DonationTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/10/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse

class DonationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    
    weak var donation: Donation! {
        didSet {
            if let donation = donation {
                nameLabel.text = "Your donation offers"
                
                if let donorUser = (PFUser.currentUser() as? User)?.donor, otherOrgUser = donation.toOrganization {
                    nameLabel.text = otherOrgUser.name // as? String
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    nameLabel.text = donation.fromDonor!.name
                }
                
                populateTimeLabel()
                populateFoodLabel()
                populateStatusLabel()
            }
            
        }
    }
    
    func populateTimeLabel() {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        if let specificTime = donation.orgSpecificTime {
            timeLabel.text = formatter.stringFromDate(specificTime)
        } else {
            timeLabel.text = "\(formatter.stringFromDate(donation.donorTimeRangeStart!)) - \(formatter.stringFromDate(donation.donorTimeRangeEnd!))"
        }
    }
    
    func populateFoodLabel() {
        var displayable = ""
        for food in donation.foodDescription {
            switch food {
            case "Grains/Beans":
                displayable += "🍞"
            case "Fruits/Veggies":
                displayable += "🍊"
            case "Meats":
                displayable += "🍗"
            case "Dairy":
                displayable += "🍼"
            case "Oils/Condiments":
                displayable += "🍦"
            case "Baked Goods":
                displayable += "🍰"
            default:
                displayable += "💬"
            }
        }
        foodLabel.text = displayable
    }
    
    func populateStatusLabel() {
        statusLabel.text = donation.donationState.rawValue
        
        var color: UIColor!
        switch statusLabel.text! {
        case "Acceptance Pending":
            color = UIColor.orangeColor()
        case "Accepted":
            color = UIColor.greenColor()
        case "Declined":
            color = UIColor.magentaColor()
        case "Completed":
            color = UIColor.grayColor()
        default:
            break
        }
        
        statusLabel.textColor = color
        timeLabel.textColor = color
        weekdayLabel.textColor = color
        
    }
}























