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
    
    @NSManaged var locationString: String?
    /// access `location` property instead
    @NSManaged var locatedAt: PFGeoPoint?
    /// identification for organizations and donors
    @NSManaged var EIN: String?
    @NSManaged var name: String
    /// String representation of donor's manager's phone number
    @NSManaged var phoneNumber: String
    /// donor's profile picture PFFile
    @NSManaged var profilePictureFile: PFFile?
    
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