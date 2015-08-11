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
                displayable += NSString(UTF8String: "\u{e604}") as! String + " "
            case "Fruits/Veggies":
                displayable += NSString(UTF8String: "\u{e603}") as! String + " "
            case "Meats":
                displayable += NSString(UTF8String: "\u{e605}") as! String + " "
            case "Dairy":
                displayable += NSString(UTF8String: "\u{e602}") as! String + " "
            case "Oils/Condiments":
                displayable += NSString(UTF8String: "\u{e601}") as! String + " "
            case "Baked Goods":
                displayable += NSString(UTF8String: "\u{e600}") as! String + " "
            default:
                displayable += NSString(UTF8String: "\u{e606}") as! String + " "
            }
        }
        foodLabel.font = UIFont(name: "FoodItems", size: 20)
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
//        timeLabel.textColor = color
//        weekdayLabel.textColor = color
        
    }
}























