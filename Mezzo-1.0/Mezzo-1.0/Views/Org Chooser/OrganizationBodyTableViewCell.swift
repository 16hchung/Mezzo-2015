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
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var unacceptableFoodLabel: UILabel!
    @IBOutlet weak var seeWebsiteButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    // MARK: Properties
    
    var weekDayHoursToDisplay: [String : (start: NSDate, end: NSDate)]!
    
    weak var organization: Organization? {
        didSet {
            if let organization = organization {
                // set availability label
                
                // set unacceptable foods label
                
                // set warning label
            }
        }
    }
    
    func stringRepOfSchedule() {
        
    }

    
}