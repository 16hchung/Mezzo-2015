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
    
    struct OrgConstants {
        static let nameProperty = "name"
        static let phoneNumProperty = "phoneNumber"
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
    
    static func getUserForOrg(org: Organization, callback: PFArrayResultBlock) {
        let userQuery = User.query()
        userQuery?.whereKey("organization", equalTo: org)
        userQuery?.findObjectsInBackgroundWithBlock(callback)
    }
    
    // MARK: donations
    
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
        donationQuery.whereKey(DonationConstants.statusProperty, notEqualTo: Donation.DonationState.Cancelled.rawValue)
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
    
    // MARK: offers
    
    static func addOfferToDonation(donation: Donation, toOrganization: Organization) {
        
        let offerObject = PFObject(className: OfferConstants.className)
        offerObject[OfferConstants.fromDonorProperty] = donation.fromDonor
        offerObject[OfferConstants.toOrgProperty] = toOrganization
        offerObject[OfferConstants.donationProperty] = donation
        offerObject[OfferConstants.statusProperty] = Donation.DonationState.Offered.rawValue
        
        var offerACL = offerObject.ACL!
        self.getUserForOrg(toOrganization, callback: { (results, error) -> Void in
            let user = results![0] as! PFUser
            offerACL.setWriteAccess(true, forUser: user)
            offerObject.ACL = offerACL
        })
        
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
    
    /**
    Accepts or declines a donation
    - Only call if current user is a recipient
    
    :param: donation (Donation) donation being responded to
    :param: byAccepting (Bool) true if accepting, false if declining
    */
    static func respondToOfferForDonation(donation: Donation, withTime: NSDate?, byAccepting: Bool, callBack: PFBooleanResultBlock?) {
        ParseHelper.getOffersForDonation(donation) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            if let result = result {
                // filter through offers
                let specificOffer = result.filter { $0[ParseHelper.OfferConstants.toOrgProperty] as? Organization == (PFUser.currentUser() as? User)?.organization }
                                // get donation for filtered offer
                let donationsToAccept = specificOffer.map { $0[ParseHelper.OfferConstants.donationProperty] as! Donation }
                
                // update offer object
                for offer in specificOffer {
                    if let offer = offer as? PFObject {
                        if byAccepting { offer[ParseHelper.OfferConstants.statusProperty] = Donation.DonationState.Accepted.rawValue }
                        else { offer[ParseHelper.OfferConstants.statusProperty] = Donation.DonationState.Declined.rawValue }
                        offer.saveInBackground()
                    }
                }
                
                // save donation state in donation object
                for donationObject in donationsToAccept {
                    
                    // set ACL to current org can edit the donation
                    var donationACL = donationObject.ACL
                    donationACL?.setWriteAccess(true, forUser: PFUser.currentUser()!)
                    donationObject.ACL = donationACL
                    
                    if byAccepting {
                        donationObject.toOrganization = (PFUser.currentUser()! as! User).organization!
                        donationObject.orgSpecificTime = withTime
                        donationObject.donationState = .Accepted
                    }
                    else { // update if it's the last org to decline
                        let pendingOffers = result.filter { $0[ParseHelper.OfferConstants.statusProperty] as! String == Donation.DonationState.Offered.rawValue }
                        if pendingOffers.isEmpty { donationObject.donationState = .Declined }
                    }
                    
                    donationObject.saveInBackgroundWithBlock(callBack)
                }
            }
        }
    }
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}




























