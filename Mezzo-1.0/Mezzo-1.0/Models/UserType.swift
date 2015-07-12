//
//  UserType.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import Foundation
import Parse

enum UserType {
    case DonorUser (Donor)
    case OrganizationUser (Organization)
}