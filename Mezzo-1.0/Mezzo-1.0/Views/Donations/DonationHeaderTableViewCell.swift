//
//  DonationHeaderTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class DonationHeaderTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var entityNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    var donation: Donation? {
        didSet {
            if let donation = donation {
                
                let displayingUser: User!
                
                if let user = user as? Organization {
                    displayingUser = donation.fromDonor
                } else {
                    displayingUser = donation.toOrganization
                }
                
                entityNameLabel.text = displayingUser.name
                
                var formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                timeLabel.text = formatter.stringFromDate(donation.pickupAt)
                
                statusLabel.text = donation.status
                
                // TODO: expand button
            }
        }
    }
    
    
}
