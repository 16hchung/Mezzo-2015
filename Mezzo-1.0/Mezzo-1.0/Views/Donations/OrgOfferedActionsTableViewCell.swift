//
//  OrgOfferedActionsTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

protocol PendingOrgActionsCellDelegate: class {
    func showTimePickingDialogue(cell: DonationHeaderTableViewCell)
    func showDeclineDialogue(cell: DonationHeaderTableViewCell)

}

class OrgOfferedActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    

}
