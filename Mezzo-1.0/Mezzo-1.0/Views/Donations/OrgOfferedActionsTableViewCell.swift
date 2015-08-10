//
//  OrgOfferedActionsTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

protocol PendingOrgActionsCellDelegate: class {
    func showTimePickingDialogue(cell: OrgOfferedActionsTableViewCell)
    func showDeclineDialogue(cell: OrgOfferedActionsTableViewCell)
}

class OrgOfferedActionsTableViewCell: UITableViewCell {

    weak var delegate: PendingOrgActionsCellDelegate!
    weak var donation: Donation!
    
    @IBAction func acceptButtonPressed(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "accept", "donation state" : donation.donationState.rawValue])
        delegate?.showTimePickingDialogue(self)
    }
    
    @IBAction func declineButtonPressed(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "decline", "donation state" : donation.donationState.rawValue])
        delegate?.showDeclineDialogue(self)
    }

}
