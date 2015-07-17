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
    
    // MARK: Donation Methods
    
    /**
        Gets all donations (includes completed, excludes cancelled) associated with the PFUser.currentUser().
        Loads the upcoming or completed donations based on `isUpcoming` argument.
    */
//    static func getDonations(#isUpcoming: Bool, completionBlock: PFArrayResultBlock) {
//        let offerQuery = PFQuery(className: OfferConstants.className)
//        
//        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
//            offerQuery.whereKey(OfferConstants.fromDonorProperty, equalTo: donorUser)
//            offerQuery.includeKey(OfferConstants.fromDonorProperty)
//        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
//            offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: orgUser)
//            offerQuery.includeKey(OfferConstants.toOrgProperty)
//        }
//        
//        if isUpcoming {
//            offerQuery.whereKey(OfferConstants.statusProperty, notEqualTo: Donation.DonationState.Completed.rawValue)
//        } else {
//            offerQuery.whereKey(OfferConstants.statusProperty, equalTo: Donation.DonationState.Completed.rawValue)
//        }
//        
//        offerQuery.includeKey(OfferConstants.donationProperty)
//        
//        offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
//    }
    

    /**
        Gets completed donations for the current user.
    */
    static func getCompletedDonations(completionBlock: PFArrayResultBlock) {
        let donationQuery = PFQuery(className: DonationConstants.className)
        
        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
            donationQuery.whereKey(DonationConstants.fromDonorProperty, equalTo: donorUser)
            donationQuery.includeKey(DonationConstants.fromDonorProperty)
        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
            donationQuery.whereKey(DonationConstants.toOrgProperty, equalTo: orgUser)
            donationQuery.includeKey(DonationConstants.toOrgProperty)
        }
        
        donationQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Completed.rawValue)
        
        donationQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
        Gets upcoming donations for the current user to display on the donationsVC page.
        IsPending is for the org's view, for loading pending donations awaiting their response
        and loadng accepted upcoming donations separately.
    */
    static func getUpcomingDonations(#isPending: Bool, completionBlock: PFArrayResultBlock) {
        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
            
            let donationQuery = PFQuery(className: DonationConstants.className)
            donationQuery.whereKey(DonationConstants.fromDonorProperty, equalTo: donorUser)
            donationQuery.includeKey(DonationConstants.fromDonorProperty)
            donationQuery.findObjectsInBackgroundWithBlock(completionBlock)
            
        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
            
            if isPending { // donations to an org that await their response
                
                let donationQuery = PFQuery(className: DonationConstants.className)
                donationQuery.whereKey(DonationConstants.toOrgProperty, equalTo: orgUser) // to current recipient user
                donationQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Accepted.rawValue) // accepted
                donationQuery.includeKey(DonationConstants.toOrgProperty)
                donationQuery.findObjectsInBackgroundWithBlock(completionBlock)
                
            } else { // donations to an org that they have accepted
                
                let offerQuery = PFQuery(className: OfferConstants.className)
                offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: orgUser)
                offerQuery.whereKey(OfferConstants.statusProperty, equalTo: Donation.DonationState.Offered.rawValue) // pending for the current recipient

                // make sure entire donation is still pending too
                let donationStatusQuery = PFQuery(className: DonationConstants.className)
                donationStatusQuery.whereKey(DonationConstants.statusProperty, equalTo: Donation.DonationState.Offered.rawValue)
                offerQuery.whereKey(OfferConstants.donationProperty, matchesQuery: donationStatusQuery)
                
                offerQuery.includeKey(OfferConstants.toOrgProperty)
                offerQuery.includeKey(OfferConstants.donationProperty)
                offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
                
            }
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
    
    static func getOfferForDonation(donation: Donation, toOrganization: Organization, callBack: PFArrayResultBlock) {
        let offerQuery = PFQuery(className: OfferConstants.className)
        offerQuery.whereKey(OfferConstants.donationProperty, equalTo: donation)
        offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: toOrganization)
        
        offerQuery.includeKey(OfferConstants.donationProperty)
        
        offerQuery.findObjectsInBackgroundWithBlock(callBack)
    }
    
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}
