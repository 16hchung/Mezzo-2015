//
//  OrganizationBodyTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class OrganizationBodyTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var missionStatementLabel: UILabel!
    // MARK: Properties
    
    weak var organization: Organization? {
        didSet {
            if let organization = organization {
                missionStatementLabel.text = organization.missionStatement
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}