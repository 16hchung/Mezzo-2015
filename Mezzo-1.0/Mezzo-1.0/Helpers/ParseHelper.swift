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
    static func getDonations(#isUpcoming: Bool, completionBlock: PFArrayResultBlock) {
        let offerQuery = PFQuery(className: OfferConstants.className)
        
        if let donorUser = (PFUser.currentUser()! as? User)?.donor {
            offerQuery.whereKey(OfferConstants.fromDonorProperty, equalTo: donorUser)
            offerQuery.includeKey(OfferConstants.toOrgProperty)
        } else if let orgUser = (PFUser.currentUser()! as? User)?.organization {
            offerQuery.whereKey(OfferConstants.toOrgProperty, equalTo: orgUser)
            offerQuery.includeKey(OfferConstants.fromDonorProperty)
        }
        
        if isUpcoming {
            offerQuery.whereKey(OfferConstants.statusProperty, notEqualTo: Donation.DonationState.Completed.rawValue)
        } else {
            offerQuery.whereKey(OfferConstants.statusProperty, equalTo: Donation.DonationState.Completed.rawValue)
        }
        
        offerQuery.includeKey(OfferConstants.donationProperty)
        
        offerQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func addOfferToDonation(donation: Donation, toOrganization: Organization) {
        
        let offerObject = PFObject(className: OfferConstants.className)
        offerObject[OfferConstants.fromDonorProperty] = donation.fromDonor
        offerObject[OfferConstants.toOrgProperty] = toOrganization
        offerObject[OfferConstants.donationProperty] = donation
        offerObject[OfferConstants.statusProperty] = Donation.DonationState.Offered.rawValue
        
        offerObject.saveInBackground()
        
    }
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}



























