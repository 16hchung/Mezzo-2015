//
//  DonationTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/6/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse

class DonationTableViewCell: UITableViewCell {

    @IBOutlet weak var foodDetailsLabel: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var contactInfoTitle: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var OfferSentToTitle: UILabel!
    
    @IBOutlet weak var cancelDonationButton: UIButton!
    @IBOutlet weak var changeRecipientButton: UIButton!
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                
                // set up potential otherUser variables
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    otherOrgUser = donation.toOrganization
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    otherDonorUser = donation.fromDonor
                } // @ this point, either donor or org is nil, not both
                
                // populate data depending on which otherUser is nil
                phoneNumberButton.titleLabel!.text = otherDonorUser?.phoneNumber ?? otherOrgUser?.phoneNumber
                
                // update the labels
                foodDetailsLabel.text = donation.detailsString()
                
                //phoneNumberButton.setTitle(otherUser.phoneNumber, forState: UIControlState.Normal)
                //locationButton.setTitle(donation.locationString(), forState: UIControlState.Normal)
                
                
                if let donorUser = (PFUser.currentUser() as? User)?.donor where donation.donationState == Donation.DonationState.Offered {
                    
                    contactInfoTitle.hidden = true
                    locationTitle.hidden = true
                    phoneNumberButton.hidden = true
                    locationButton.hidden = true
                    
                } else {
                    
                    cancelDonationButton.hidden = true
                    changeRecipientButton.hidden = true
                    OfferSentToTitle.hidden = true
                    
                    var someNumber = 3
                    
                    let potentialRecipientLabels = [OfferSentToTitle] + [UILabel](count: someNumber, repeatedValue: UILabel())
                    
                    for label in potentialRecipientLabels {
                        
                    }
                    
                    
                }
                
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