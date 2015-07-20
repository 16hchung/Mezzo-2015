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
        static let className = "Donation"
        
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
    
    static func getAllOrgs(completionBlock: PFArrayResultBlock) {
        let orgsQuery = Organization.query()!
        // TODO: load the __ number of closest and highest priority organizations
        // TODO: sort by times, desired foods
        orgsQuery.orderByAscending(OrgConstants.nameProperty) // filler sort
        
        orgsQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
        Gets completed donations for the current user.
    */
    static func getCompletedDonations(completionBlock: PFArrayResultBlock) {
        let donationQuery = PFQuery(className: DonationConstants.className)
        
        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
            donationQuery.whereKey(DonationConstants.fromDonorProperty, equalTo: donorUser)
            donationQuery.includeKey(DonationConstants.toOrgProperty)
        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
            donationQuery.whereKey(DonationConstants.toOrgProperty, equalTo: orgUser)
            donationQuery.includeKey(DonationConstants.fromDonorProperty)
        }
        
        donationQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Completed.rawValue)
        
        donationQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
        Gets upcoming (not completed) donations for the current donor.
    */
    static func getUpcomingDonationsForDonor(#donorUser: Donor, completionBlock: PFArrayResultBlock) {
        let donationQuery = PFQuery(className: DonationConstants.className)
        donationQuery.includeKey(DonationConstants.toOrgProperty)
        donationQuery.whereKey(DonationConstants.fromDonorProperty, equalTo: donorUser) // from the donor user passed in
        donationQuery.whereKey(DonationConstants.statusProperty, notEqualTo: Donation.DonationState.Completed.rawValue) // not completed yet
        donationQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
        Gets upcoming donations for the current recipient user.
    
        :param: isPending If true, returns pending offers for the recipient. If false, returns accepted donations for recipient.
    */
    static func getUpcomingDonationsForRecipient(#orgUser: Organization, isPending: Bool, completionBlock: PFArrayResultBlock) {
        if isPending {
            
            let offerQuery = PFQuery(className: OfferConstants.className)
            offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: orgUser)
            offerQuery.whereKey(OfferConstants.statusProperty, equalTo: Donation.DonationState.Offered.rawValue) // pending for the current recipient
            
            // make sure entire donation is still pending too
            let donationStatusQuery = PFQuery(className: DonationConstants.className)
            donationStatusQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Offered.rawValue)
            offerQuery.whereKey(OfferConstants.donationProperty, matchesQuery: donationStatusQuery)
            
            offerQuery.includeKey(OfferConstants.donationProperty)
            offerQuery.includeKey("\(OfferConstants.donationProperty).\(DonationConstants.fromDonorProperty)")
            offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
            
        } else {
            
            let donationQuery = PFQuery(className: DonationConstants.className)
            donationQuery.whereKey(DonationConstants.toOrgProperty, equalTo: orgUser) // to current recipient user
            donationQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Accepted.rawValue) // accepted
            donationQuery.includeKey(DonationConstants.toOrgProperty)
            donationQuery.includeKey(DonationConstants.fromDonorProperty)
            donationQuery.findObjectsInBackgroundWithBlock(completionBlock)

        }
    }
    
    
    static func addOfferToDonation(donation: Donation, toOrganization: Organization) {
        
        let offerObject = PFObject(className: OfferConstants.className)
        offerObject[OfferConstants.fromDonorProperty] = donation.fromDonor
        offerObject[OfferConstants.toOrgProperty] = toOrganization
        offerObject[OfferConstants.donationProperty] = donation
        offerObject[OfferConstants.statusProperty] = Donation.DonationState.Offered.rawValue
        
        offerObject.saveInBackground()
        
    }
    
    /**
        Get all the offers for a given donation object.
    */
    static func getOffersForDonation(donation: Donation, callBack: PFArrayResultBlock) {
        let offerQuery = PFQuery(className: OfferConstants.className)
        offerQuery.whereKey(OfferConstants.donationProperty, equalTo: donation)
        offerQuery.includeKey(OfferConstants.donationProperty)
        offerQuery.includeKey(OfferConstants.fromDonorProperty)
        offerQuery.includeKey(OfferConstants.toOrgProperty)
        offerQuery.findObjectsInBackgroundWithBlock(callBack)
    }
    
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}




























