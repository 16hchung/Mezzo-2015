//
//  User.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

class User: PFUser, PFSubclassing {
    //My variables
    @NSManaged var donor: Donor?
    @NSManaged var organization: Organization?
    
    
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