//
//  Donor.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

class Donor: PFObject, PFSubclassing {
    
    // MARK: from Parse
    
    /// login info from Parse (don't need to use often)
    @NSManaged var user: PFUser?
    /// access `location` property instead
    @NSManaged var locatedAt: PFGeoPoint?
    /// identification for organizations and donors
    @NSManaged var EIN: String?
    @NSManaged var businessName: String
    /// String representation of donor's manager's phone number
    @NSManaged var phoneNumber: String
    /// donor's profile picture PFFile
    @NSManaged var profilePictureFile: PFFile?
    
    // MARK: Methods
    
    // TODO: create Donation/Org classes + uncomment => implement
    /**
        Creates new `Donation` object and sends out offer
        
        :param: atTime suggested time of donation's pickup
        :param: toOrganization organization receiving the offer
    */
    func offerADonation(atTime: NSDate, toOrganization: Organization) {
        
    }
    
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Donor"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}