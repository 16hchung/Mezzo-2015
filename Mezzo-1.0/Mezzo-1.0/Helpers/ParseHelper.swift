//
//  ParseHelper.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    // MARK: Parse property string constants
    
    // names (String constants) of Donor's properties in Parse
    private struct DonorConstants {
    }
    
    private struct OrgConstants {
        static let nameProperty = "name"
    }
    
    private struct DonationConstants {
        static let fromDonorProperty  = "fromDonor"
        static let toOrgProperty      = "toOrganization"
        static let statusProperty     = "status"
        
        static let proposedTimeRangeStart = "donorTimeRangeStart"
        static let proposedTimeRangeEnd = "donorTimeRangeEnd"
        static let actualPickupTime = "orgSpecificTime"
    }
    
    struct OfferConstants {
        static let className = "Offer"
        static let toOrgProperty = "toOrganization"
        static let fromDonorProperty = "fromDonor"
        static let donationProperty = "donation"
        static let statusProperty = "status"
    }
    
    // MARK: User Methods
    
//    /**
//        Queries Donor and Organization tables in Parse to figure out if
//        current logged in PFUser is a donor or an organization.
//    
//        :returns: object that conforms to User protocol
//    */
//    static func getUserType(fromUser: PFUser?) -> User? {
//        // check if fromUser is a donor
//        let donorQuery = Donor.query()
//        donorQuery!.whereKey(DonorConstants.userProperty, equalTo:PFUser.currentUser()!)
//        
//        // TODO: convert to doing in the background
//        let maybeDonor = donorQuery!.findObjects()
//        if let donor = maybeDonor!.last as? Donor {
//            return donor
//        }
//        
//        //check if fromUser is an org
//        let orgQuery = Organization.query()
//        orgQuery!.whereKey(OrgConstants.userProperty, equalTo:PFUser.currentUser()!)
//        
//        let maybeOrg = orgQuery!.findObjects()
//        if let organization = maybeOrg!.last as? Organization {
//            return organization
//        }
//        
//        return nil
//    }
    
    static func getAllOrgs(completionBlock: PFArrayResultBlock) {
        let orgsQuery = Organization.query()!
        // TODO: load the __ number of closest and highest priority organizations
        // TODO: sort by times, desired foods
        orgsQuery.orderByAscending(OrgConstants.nameProperty) // filler sort
        
        orgsQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Donation Methods
    
//    /**
//        Gets all donations (includes completed, excludes cancelled) from a given donor.
//        Loads the upcoming or completed donations based on `isUpcoming` argument.
//    */
//    static func getDonations(#fromDonor: Donor, isUpcoming: Bool, completionBlock: PFArrayResultBlock) {
//        let offerQuery = PFQuery(className: OfferConstants.className)
//        
//        offerQuery.whereKey(OfferConstants.fromDonorProperty, equalTo: (PFUser.currentUser()! as! User).donor!)
//        offerQuery.includeKey(OfferConstants.donationProperty)
//        offerQuery.includeKey(OfferConstants.toOrgProperty)
//        
//        offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
//    }
//    
//    
//    static func getDonations(#toOrg: Organization, isUpcoming: Bool, completionBlock: PFArrayResultBlock) {
//        let offerQuery = PFQuery(className: OfferConstants.className)
//        
//        offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: (PFUser.currentUser()! as! User).organization!)
//        offerQuery.includeKey(OfferConstants.donationProperty)
//        offerQuery.includeKey(OfferConstants.fromDonorProperty)
//        
//        offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
//        
//    }
    
    /**
        Gets all donations (includes completed, excludes cancelled) associated with the PFUser.currentUser().
        Loads the upcoming or completed donations based on `isUpcoming` argument.
    */
    static func getDonations(#isUpcoming: Bool, completionBlock: PFArrayResultBlock) {
        let offerQuery = PFQuery(className: OfferConstants.className)
        
        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
            offerQuery.whereKey(OfferConstants.fromDonorProperty, equalTo: donorUser)
            offerQuery.includeKey(OfferConstants.toOrgProperty)
        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
            offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: orgUser)
            offerQuery.includeKey(OfferConstants.fromDonorProperty)
        }
        offerQuery.includeKey(OfferConstants.donationProperty)
        
        offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
//    /**
//        Adds to an existing Donation query. Gets un-cancelled donations that are either upcoming
//        or past and already completed.
//    */
//    private static func getUpcomingOrCompletedDonations(query: PFQuery, isUpcoming: Bool) {
//        query.whereKey(DonationConstants.statusProperty,
//            notEqualTo: Donation.DonationState.Cancelled.rawValue) // not cancelled
//        
//        if (isUpcoming) {
//            query.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Offered.rawValue)
//            
//            //query.whereKey(DonationConstants.dateProperty, greaterThanOrEqualTo: NSDate()) // future dates
//        } else {
//            query.whereKey(DonationConstants.dateProperty, lessThan: NSDate()) // past dates
//            query.whereKey(DonationConstants.statusProperty,
//                equalTo: Donation.DonationState.Completed.rawValue) // completed
//        }
//    }
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}





















