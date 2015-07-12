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
    
    var donation: Donation? {
        didSet {
            if let donation = donation {
                let displayingUser: User!
                
                if let user = user as? Organization {
                    displayingUser = donation.fromDonor
                } else {
                    displayingUser = donation.toOrganization
                }
                
                
                foodDetailsLabel.text = donation.detailsString()
                phoneNumberButton.setTitle(displayingUser.phoneNumber, forState: UIControlState.Normal)
//                locationButton.setTitle(donation.location, forState: UIControlState.Normal)
            }
        }
    }
}
