//
//  DonationHeaderTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse

class DonationHeaderTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var entityNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    @IBOutlet weak var acceptButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var donationDatePicker: UIDatePicker!
    @IBOutlet weak var datePickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedTimeLabel: UILabel!
    @IBOutlet weak var pickupTimeDescriptionLabel: UILabel!
    @IBOutlet weak var selectTimeButton: UIButton!
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                if let orgUser = (PFUser.currentUser() as? User)?.organization where donation.donationState == Donation.DonationState.Offered {
                    showAcceptAndDeclineButtons()
                } else {
                    hideAcceptAndDeclineButtons()
                }
                
                hideTimePickingRelatedViews()
                
                var entityName: String = "Today's donation offer"
                
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    otherOrgUser = donation.toOrganization
                    if donation.donationState != Donation.DonationState.Offered && donation.donationState != Donation.DonationState.Declined {
                        entityName = otherOrgUser?["name"] as! String
                    }
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    otherDonorUser = donation.fromDonor
                    entityName = otherDonorUser?["name"] as! String
                } // @ this point, either donor or org is nil, not both
                
                entityNameLabel.text = entityName
                var formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                if let specificTime = donation.orgSpecificTime {
                    timeLabel.text = formatter.stringFromDate(specificTime)
                } else {
                    timeLabel.text = "\(formatter.stringFromDate(donation.donorTimeRangeStart!))-\(formatter.stringFromDate(donation.donorTimeRangeEnd!))"
                }
                
                statusLabel.text = donation.donationState.rawValue
            }
        }
    }
    @IBAction func dateValueChanged(sender: UIDatePicker) {
        var formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        selectedTimeLabel.text = formatter.stringFromDate(sender.date)
    }
    
    @IBAction func selectTime(sender: UIButton) {
        hideTimePickingRelatedViews()
        hideAcceptAndDeclineButtons()
        donation.orgSpecificTime = donationDatePicker.date
        donation.saveInBackground()
    }
    
    @IBAction func acceptDonation(sender: UIButton) {
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            ParseHelper.respondToOfferForDonation(donation, byAccepting: true)
        }
        acceptButton.selected = true
        declineButton.enabled = false
        showTimePickingRelatedViews()
        
    }
    
    @IBAction func declineDonation(sender: UIButton) {
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            ParseHelper.respondToOfferForDonation(donation, byAccepting: false)
        }
        hideTimePickingRelatedViews()
        hideAcceptAndDeclineButtons()
    }
    
    private func showTimePickingRelatedViews() {
        datePickerBottomConstraint.active = true
        
        donationDatePicker.hidden = false
        selectedTimeLabel.hidden = false
        selectTimeButton.hidden = false
        pickupTimeDescriptionLabel.hidden = false
        
        
    }
    
    private func hideTimePickingRelatedViews() {
        donationDatePicker.hidden = true
        selectedTimeLabel.hidden = true
        selectTimeButton.hidden = true
        pickupTimeDescriptionLabel.hidden = true
        datePickerBottomConstraint.active = false
    }
    
    private func showAcceptAndDeclineButtons() {
        declineButton.hidden = false
        acceptButton.hidden = false
        
        acceptButton.titleLabel!.font = UIFont(name: acceptButton.titleLabel!.font.fontName, size: 15.0)
        declineButton.titleLabel!.font = UIFont(name: declineButton.titleLabel!.font.fontName, size: 15.0)
        
        acceptButtonHeightConstraint.constant = 31
        acceptButtonBottomConstraint.constant = 16
    }
    
    private func hideAcceptAndDeclineButtons() {
        declineButton.hidden = true
        acceptButton.hidden = true
        
        acceptButton.titleLabel!.font = UIFont(name: acceptButton.titleLabel!.font.fontName, size: 0.0)
        declineButton.titleLabel!.font = UIFont(name: declineButton.titleLabel!.font.fontName, size: 0.0)
        
        acceptButtonHeightConstraint.constant = 0
        acceptButtonBottomConstraint.constant = 0
    }
    
    
    
}
