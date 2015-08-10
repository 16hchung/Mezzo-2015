//
//  CancelTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

protocol CancelCellDelegate: class {
    func cancelDonation(cell: CancelTableViewCell)
}

class CancelTableViewCell: UITableViewCell {

    weak var donation: Donation!
    weak var delegate: CancelCellDelegate!
    
    @IBAction func cancelDonation(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "canceled", "donation state" : donation.donationState.rawValue])
        delegate?.cancelDonation(self)
    }

}
