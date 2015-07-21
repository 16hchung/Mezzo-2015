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
    
    // MARK: constraints
    
    @IBOutlet weak var contactInfoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelDonationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerSentToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pendingOrgListBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pendingStatusListBottomConstraint: NSLayoutConstraint!
    
    var pendingOffers: [PFObject]?
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                hideCancelledOptions(true)
                
                // set up potential otherUser variables
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    otherOrgUser = donation.toOrganization
                    
                    hideLocation(true)
                    
                    if donation.donationState == Donation.DonationState.Offered || donation.donationState == Donation.DonationState.Declined {
                        
                        hideContactInfo(true)
                        
                        hideOffers(false)
                        
                        if let pendingOffers = pendingOffers {
                            pendingOrgListLabel.text = ""
                            pendingOrgStatusesLabel.text = ""
                            if pendingOffers.count < 1 {
                                pendingOrgListLabel.numberOfLines = 1
                                pendingOrgStatusesLabel.numberOfLines = 1
                            } else {
                                pendingOrgListLabel.numberOfLines = pendingOffers.count * 2
                                pendingOrgStatusesLabel.numberOfLines = pendingOffers.count * 2

                            }
                            
                            println(pendingOffers)
                            
                            for offer in pendingOffers {
                                pendingOrgListLabel.text! += "\(offer.objectForKey(ParseHelper.OfferConstants.toOrgProperty)!.objectForKey(ParseHelper.OrgConstants.nameProperty)!)\n\n"
                                pendingOrgStatusesLabel.text! += "\(offer[ParseHelper.OfferConstants.statusProperty]!)\n\n"
                            }
                        }
                        
                        if donation.donationState == Donation.DonationState.Declined {
                            hideCancelledOptions(false)
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
    
    // collapses/shows buttons or labels
    private func setFontOfUIObject(object: AnyObject, normalFontSize: CGFloat, hidden: Bool) {
        if let button = object as? UIButton {
            button.hidden = hidden
            let fontSize: CGFloat = hidden ? 0.0 : normalFontSize
            button.titleLabel!.font = UIFont(name: button.titleLabel!.font.fontName, size: fontSize)
        } else if let label = object as? UILabel {
            label.hidden = hidden
            let fontSize: CGFloat = hidden ? 0.0 : normalFontSize
            label.font = UIFont(name: label.font.fontName, size: fontSize)
        }
    }
    
    private func hideLocation(hidden: Bool) {
        setFontOfUIObject(locationTitle, normalFontSize: 14.0, hidden: hidden)
        setFontOfUIObject(locationButton, normalFontSize: 14.0, hidden: hidden)
        
        locationBottomConstraint.constant = hidden ? -15 : 10
    }
    
    private func hideContactInfo(hidden: Bool) {
        setFontOfUIObject(contactInfoTitle, normalFontSize: 14.0 , hidden: hidden)
        setFontOfUIObject(phoneNumberButton, normalFontSize: 14.0 , hidden: hidden)
        
        contactInfoBottomConstraint.constant = hidden ? -20 : 10
    }
    
    private func hideCancelledOptions(hidden: Bool) {
        setFontOfUIObject(cancelDonationButton, normalFontSize: 15.0, hidden: hidden)
        setFontOfUIObject(changeRecipientButton, normalFontSize: 15.0, hidden: hidden)
        
        cancelDonationBottomConstraint.constant = hidden ? 0 : -16
    }
    
    private func hideOffers(hidden: Bool) {
        setFontOfUIObject(OfferSentToTitle, normalFontSize: 14.0, hidden: hidden)
        setFontOfUIObject(pendingOrgListLabel, normalFontSize: 12.0, hidden: hidden)
        setFontOfUIObject(pendingOrgStatusesLabel, normalFontSize: 12.0, hidden: hidden)
        
        offerSentToBottomConstraint.constant = hidden ? 0 : 8
        pendingStatusListBottomConstraint.constant = hidden ? 0 : 8
        pendingOrgListBottomConstraint.constant = hidden ? 0 : 8
    }
}