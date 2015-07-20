//
//  Donor.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

class Organization: PFObject, PFSubclassing{
    
    // MARK: Parse attributes
    
    @NSManaged var locatedAt: PFGeoPoint?
    @NSManaged var EIN: String?
    @NSManaged var name: String
    /// String representation of organization's manager's phone number
    @NSManaged var phoneNumber: String
    @NSManaged var missionStatement: String
    @NSManaged var availableTimes: [String]
    /// org's profile picture PFFile
    @NSManaged var profilePictureFile: PFFile?
    
    // MARK: Methods
    
    // TODO: implement cancel method
    /**
        Cancels donation (only an organization can do this)
    
        :param: donation object to be cancelled
    */
    func cancelDonation(#donation: Donation) {
        // confirm that the donation is meant for this organization?
        // delete from Parse (or add a cancelled flag?)
        // notify donor of this donation
    }
    
    /**
        Accepts or declines a donation
    
        :param: donation (Donation) donation being responded to
        :param: byAccepting (Bool) true if accepting, false if declining
    */
    func respondToOfferForDonation(donation: Donation, byAccepting: Bool) {
        ParseHelper.getOffersForDonation(donation) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            if let result = result {
                // filter through offers
                let specificOffer = result.filter { $0[ParseHelper.OfferConstants.toOrgProperty] as! Organization == self }
                
                
                // get donation for filtered offer
                let donationsToAccept = specificOffer.map { $0[ParseHelper.OfferConstants.donationProperty] as! Donation }
                
                // save donation state in donation object
                for donationObject in donationsToAccept {
                    donationObject.toOrganization = (PFUser.currentUser()! as! User).organization!
                    
                    if byAccepting { donationObject.donationState = .Accepted }
                    else { // update if it's the last org to decline
                        let pendingOffers = result.filter { $0[ParseHelper.OfferConstants.statusProperty] as! String == Donation.DonationState.Offered.rawValue }
                        if pendingOffers.isEmpty { donationObject.donationState = .Declined }
                    }
                    
                    donationObject.saveInBackground()
                }
                
                // update offer object
                for offer in specificOffer {
                    if let offer = offer as? PFObject {
                        if byAccepting { offer[ParseHelper.OfferConstants.statusProperty] = Donation.DonationState.Accepted.rawValue }
                        else { offer[ParseHelper.OfferConstants.statusProperty] = Donation.DonationState.Declined.rawValue }
                        offer.saveInBackground()
                    }
                }
            }
        }
    }
    
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Organization"
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
