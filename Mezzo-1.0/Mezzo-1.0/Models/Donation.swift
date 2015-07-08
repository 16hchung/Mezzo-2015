//
//  Donation.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/8/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

class Donation: PFObject, PFSubclassing {
    
    // MARK: Properties from Parse
    
    @NSManaged var fromDonor: Donor?
    @NSManaged var toOrganization: Organization?
    /// time of food pickup
    @NSManaged var pickupAt: NSDate
    /// description of donation
    @NSManaged var foodDescription: String
    
    // MARK: Other Properties
    
    /// states: Requested, Confirmed, Cancelled, Completed
    enum DonationState: Int {
        case Requested = 0
        case Confirmed = 1
        case Cancelled = 2
        case Completed = 3
    }
    
    private var donationState = DonationState.Requested
    
    // MARK: Methods
    
    // TODO: implement nextState method (use raw values?)
    /**
        switches through states of Donation
    */
    private func nextState() {
        
    }
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Donation"
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