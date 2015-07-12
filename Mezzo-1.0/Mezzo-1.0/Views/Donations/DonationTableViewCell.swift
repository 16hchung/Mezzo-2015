//
//  DonationTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/6/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class DonationTableViewCell: UITableViewCell {

    @IBOutlet weak var foodDetailsLabel: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                // get the other user (to grab their phone number)
                let otherUser: User!
                if let user = user as? Organization {
                    otherUser = donation.fromDonor
                } else {
                    otherUser = donation.toOrganization
                }
                
                // update the labels
                foodDetailsLabel.text = donation.detailsString()
                phoneNumberButton.titleLabel!.text = otherUser.phoneNumber
                //phoneNumberButton.setTitle(otherUser.phoneNumber, forState: UIControlState.Normal)
                //locationButton.setTitle(donation.locationString(), forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func dialPhoneNumber(sender: AnyObject) {
        if let button = sender as? UIButton {
            let oldPhone:String! = button.titleLabel?.text ?? ""
        
            var newPhone = ""
            
            for index in oldPhone.startIndex..<oldPhone.endIndex{
                let charAtIndex = oldPhone[index]
                
                switch charAtIndex {
                case "0","1","2","3","4","5","6","7","8","9":
                    newPhone = newPhone + String(charAtIndex)
                default:
                    println("Removed invalid character.")
                }
            }
            
            if let url = NSURL(string: "tel://\(button.titleLabel?.text)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}