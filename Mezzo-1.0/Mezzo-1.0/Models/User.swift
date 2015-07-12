//
//  User.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

protocol User {
    var user: PFUser? { get set }
    var locatedAt: PFGeoPoint? { get set }
    var EIN: String? { get set }
    var name: String { get set }
    var phoneNumber: String { get set }
    var profilePictureFile: PFFile? { get set }
}