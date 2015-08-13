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

    weak var delegate: PickupConfirmationCellDelegate!
    weak var donation: Donation! {
        didSet {
            UIHelper.colorButtons([yesButton], color: UIHelper.Colors.acceptedGreen, bold: true)
            UIHelper.colorButtons([noButton], color: UIHelper.Colors.completedGray, bold: false)
        }
    }
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
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
