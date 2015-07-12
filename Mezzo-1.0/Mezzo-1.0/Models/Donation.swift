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
    /// description of donation (list of comma separated food types)
    @NSManaged var foodDescription: String
    /// String representation of weight range
    @NSManaged var weightRange: String
    /// fromParse (use DonationState)
    @NSManaged var status: String
    
    // MARK: Other Properties
    
    /// states: Requested, Confirmed, Cancelled, Completed
    enum DonationState: String {
        case Offered = "Acceptance Pending"
        case Accepted = "Accepted"
        case Declined = "Declined"
        case Cancelled = "Cancelled"
        case Completed = "Completed"
    }
    
    private var donationState: DonationState! {
        set(newState) { // updates Parse's status string
            status = newState.rawValue
        }
        get { // makes sure donationState is in sync with Parse
            return statusStringToStateInt()
        }
    }
    
    // MARK: Methods
    
    /** 
        Returns a string with a summary of the donation details (for use in the table view).
    
        :returns: summary string
    */
    func detailsString() -> String {
        return "\(foodDescription) | \(weightRange) lbs"
    }
    
    // TODO: grab the actual address from the geo point
    func locationString() -> String {
        //        return toOrganization?.locatedAt?.description
        return "1234 Hippo Lane, Palo Alto, CA" // filler data
    }
    
    // MARK: Helpers
    /**
        Converts donation status string stored in Parse to the Swift-stored
        `donationState` enum. Called every time someone tries to get the value
        of `donationState`.
    
        :returns: the appropriate `DonationState` enum
    */
    private func statusStringToStateInt() -> DonationState {
        switch(status) {
        case "Acceptance Pending":
            return .Offered
        case "Accepted":
            return .Accepted
        case "Declined":
            return .Declined
        case "Cancelled":
            return .Cancelled
        case "Completed":
            return .Completed
        default:
            return .Offered
        }
    }
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Donation"
    }
    
    override init() {
        super.init()
        self.donationState = .Offered
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}