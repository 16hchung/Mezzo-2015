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
    
    // names (String constants) of Donor's properties in Parse
    private struct DonorConstants {
        static let userProperty = "user"
    }
    
    private struct OrgConstants {
        static let userProperty = "user"
    }
    
    /**
        Queries Donor and Organization tables in Parse to figure out if
        current logged in PFUser is a donor or an organization.
    
        :returns: 
    */
    static func getUserType(fromUser: PFUser?) -> User? {
        // check if fromUser is a donor
        let donorQuery = Donor.query()
        donorQuery!.whereKey(DonorConstants.userProperty, equalTo:PFUser.currentUser()!)
        
        // TODO: convert to doing in the background
        let maybeDonor = donorQuery!.findObjects()
        if let donor = maybeDonor!.last as? Donor {
            return donor
        }
        
        //check if fromUser is an org
        let orgQuery = Organization.query()
        orgQuery!.whereKey(OrgConstants.userProperty, equalTo:PFUser.currentUser()!)
        
        let maybeOrg = orgQuery!.findObjects()
        if let organization = maybeOrg!.last as? Organization {
            return organization
        }
        
        return nil
    }
}

extension PFObject: Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}