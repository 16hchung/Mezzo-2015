//
//  PickupConfirmationTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

protocol PickupConfirmationCellDelegate: class {
    func completeDonation(cell: PickupConfirmationTableViewCell)
    func showNeverPickedUpDialogue(cell: PickupConfirmationTableViewCell)
}

class PickupConfirmationTableViewCell: UITableViewCell {

    weak var donation: Donation!
    weak var delegate: PickupConfirmationCellDelegate!
    
    @IBAction func donationCompleted(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "pickup completed", "donation state" : donation.donationState.rawValue])
        
        delegate?.completeDonation(self)
    }
    
    @IBAction func donationNeverCompleted(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "pickup never completed", "donation state" : donation.donationState.rawValue])
        delegate?.showNeverPickedUpDialogue(self)
    }
    
}
