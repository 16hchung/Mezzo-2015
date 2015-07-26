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
    
    /// description of donation (list of comma separated food types)
    @NSManaged var foodDescription: [String]
    /// String representation of donation size (number + boxes/pallets)
    @NSManaged var size: String
    /// fromParse (use DonationState)
    @NSManaged private var status: String
    
    /// start of donor-proposed time range
    @NSManaged var donorTimeRangeStart: NSDate?
    /// actual pickup time specified by Organization
    @NSManaged var orgSpecificTime: NSDate?
    /// end of donor-proposed time range
    @NSManaged var donorTimeRangeEnd: NSDate?
    
    // MARK: Other Properties
    
    /// states: Requested, Confirmed, Cancelled, Completed
    enum DonationState: String {
        case Offered = "Acceptance Pending"
        case Accepted = "Accepted"
        case Declined = "Declined"
        case Cancelled = "Cancelled"
        case Completed = "Completed"
    }
    
    var donationState: DonationState {
        set(newState) { // updates Parse's status string
            status = newState.rawValue
        }
        get { // makes sure donationState is in sync with Parse
            return statusStringToStateInt()
        }
    }
    
    /// 8 food types
    static let foodTypes: [String] = ["Grains", "Fruits/Veggies", "Meats/Beans",
        "Dairy", "Oils", "Desserts", "Condiments", "Other"]
    
    static let pluralSizeTypes: [String] = ["boxes", "pallets"]
    static let singularSizeTypes: [String] = ["box", "pallet"]
    
    // MARK: Methods
    
    /// Uploads donation to Parse (with all fields populated except state)
    func offer(callback: PFBooleanResultBlock ) {
        donationState = .Offered
        self.saveInBackgroundWithBlock(callback)
    }
    
    /**
        Returns a string with a summary of the donation details (for use in the table view).
    
        :returns: summary string
    */
    func detailsString() -> String {
        let joinedDescriptionList = join(", ", foodDescription)
        return "\(joinedDescriptionList) | \(size)"
    }
    
    // TODO: grab the actual address from the geo point
    func locationString() -> String {
        //        return toOrganization?.locatedAt?.description
        return "1234 Hippo Lane, Palo Alto, CA" // filler data
    }
    
    /**
        Checks if the current donation is already expired or completed (the pickup time range
        or specific pickup time has already passed).
    
        :returns: whether the donation should be displayed (either marked as complete now or just shouldn't be shown)
    */
    func checkIfExpiredOrCompleted() -> Bool {
        // if past today's date      
        if donorTimeRangeEnd < NSDate() || (orgSpecificTime != nil && orgSpecificTime < NSDate()) {
            // don't mark pending or declined donations that have expired as complete
            
            if donationState == .Accepted { // mark expired accpeted donations as complete
                donationState = .Completed
                self.saveInBackground()
            }
            return false // should not be displayed
        }
        return true // should be displayed
    }
    
    /// Returns appropriate color for a donation's state
    func stateToColor() -> UIColor {
        switch (donationState) {
        case .Accepted:
            return UIColor.greenColor()
        case .Offered:
            return UIColor.orangeColor()
        case .Declined:
            return UIColor.redColor()
        case .Completed:
            return UIColor.grayColor()
        default:
            return UIColor.blackColor()
        }
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
//        self.donationState = .Offered
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}

extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}











