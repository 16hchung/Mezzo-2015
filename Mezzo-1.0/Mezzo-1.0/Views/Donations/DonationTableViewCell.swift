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
    
    @IBOutlet weak var pendingOrgListLabel: UILabel!
    @IBOutlet weak var pendingOrgStatusesLabel: UILabel!
    
    var pendingOffers: [PFObject]?
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                cancelDonationButton.hidden = true
                changeRecipientButton.hidden = true
                
                // set up potential otherUser variables
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    otherOrgUser = donation.toOrganization
                    
                    locationButton.hidden = true
                    locationTitle.hidden = true
                    
                    if donation.donationState == Donation.DonationState.Offered || donation.donationState == Donation.DonationState.Declined {
                        
                        contactInfoTitle.hidden = true
                        phoneNumberButton.hidden = true
                        
                        OfferSentToTitle.hidden = false
                        
                        if let pendingOffers = pendingOffers {
                            pendingOrgListLabel.text = ""
                            pendingOrgStatusesLabel.text = ""
                            pendingOrgListLabel.numberOfLines = pendingOffers.count * 2
                            pendingOrgStatusesLabel.numberOfLines = pendingOffers.count * 2
                            
                            println(pendingOffers)
                            
                            for offer in pendingOffers {
                                pendingOrgListLabel.text! += "\((offer[ParseHelper.OfferConstants.toOrgProperty] as! Organization).name)\n\n"
                                pendingOrgStatusesLabel.text! += "\(offer[ParseHelper.OfferConstants.className])\n\n"
                            }
                        }
                        
                        if donation.donationState == Donation.DonationState.Declined {
                            cancelDonationButton.hidden = false
                            changeRecipientButton.hidden = false
                        }
                        
                    }
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    otherDonorUser = donation.fromDonor
                } // @ this point, either donor or org is nil, not both
                
                // populate data depending on which otherUser is nil
                phoneNumberButton.titleLabel!.text = otherDonorUser?.phoneNumber ?? otherOrgUser?.phoneNumber ?? ""
                
                // update the labels
                foodDetailsLabel.text = donation.detailsString()
                
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