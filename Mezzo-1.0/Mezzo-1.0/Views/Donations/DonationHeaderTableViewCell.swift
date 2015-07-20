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
    
    var donation: Donation! {
        didSet {
            if let donation = donation {
                
                if let orgUser = (PFUser.currentUser() as? User)?.organization where donation.donationState == Donation.DonationState.Offered {
                    declineButton.hidden = false
                    acceptButton.hidden = false
                } else {
                    declineButton.removeFromSuperview()
                    acceptButton.removeFromSuperview()
                }
                
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    otherOrgUser = donation.toOrganization
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    otherDonorUser = donation.fromDonor
                } // @ this point, either donor or org is nil, not both
                
                entityNameLabel.text = otherDonorUser?["name"] as? String ?? otherOrgUser?["name"] as? String
                var formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                timeLabel.text = formatter.stringFromDate(donation.orgSpecificTime!)
                
                statusLabel.text = donation.donationState.rawValue
            }
        }
    }
    
    
}
