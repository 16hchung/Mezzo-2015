//
//  OrganizationHeaderTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class OrganizationHeaderTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    // MARK: Properties
    
    var organization: Organization? {
        didSet {
            if let organization = organization {
                orgNameLabel.text = organization.name
            }
        }
    }
    
    @IBAction func checkBoxSelected(sender: UIButton) {
        
        checkBoxButton.selected = !checkBoxButton.selected
        
    }
    

}
