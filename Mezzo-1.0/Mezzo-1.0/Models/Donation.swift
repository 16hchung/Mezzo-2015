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
        case Incomplete = "Incomplete" // donation was accepted, but pick up was never completed
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
    
    static let pluralSizeTypes: [String] = ["boxes", "carts", "pallets"]
    static let singularSizeTypes: [String] = ["box", "cart", "pallet"]
    
    // MARK: Methods
    
    /// Uploads donation to Parse (with all fields populated except state)
    func offer(fromDonor: Donor, toOrgs: [Organization], callback: PFBooleanResultBlock ) {
        donationState = .Offered
        self.fromDonor = fromDonor
        
        var donationACL = self.ACL!
        for org in toOrgs {
            ParseHelper.getUserForOrg(org, callback: { (results, error) -> Void in
                let user = results![0] as! PFUser
                donationACL.setWriteAccess(true, forUser: user)
                if org == toOrgs.last {
                    self.ACL = donationACL
                    self.saveInBackgroundWithBlock(callback)
                }
            })
        }
    }
    
    func setDonationState(state: DonationState, callback: PFBooleanResultBlock) {
        donationState = state
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
    
    func locationString() -> String {
        var returnedString = ""
        
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            returnedString = fromDonor?.locationString ?? ""
        } else if let donorUser = (PFUser.currentUser() as? User)?.donor {
            returnedString = toOrganization?.locationString ?? ""
        }
        
        return returnedString
    }
    
    /**
        Returns lat and long of locatedAt property based on who is the currentUser
        
        :returns: latitude, longitude optional doubles
    */
    func location() -> (latitude: Double?, longitude: Double?) {
        var toReturn: (latitude: Double?, longitude: Double?) = (nil, nil)
        
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            toReturn.latitude = fromDonor?.locatedAt?.latitude
            toReturn.longitude = fromDonor?.locatedAt?.longitude
        } else if let donorUser = (PFUser.currentUser() as? User)?.donor {
            toReturn.latitude = toOrganization?.locatedAt?.latitude
            toReturn.longitude = toOrganization?.locatedAt?.longitude
        }
        
        return toReturn
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











