//
//  MezzoLoginViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/28/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MezzoLoginViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let logoView = UIImageView(image: UIImage(named: "Logo"))
//        logoView.addConstraint(NSLayoutConstraint(item: logoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: logoView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        self.logInView!.logo = logoView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        logInView!.logo!.addConstraint(NSLayoutConstraint(item: logInView!.logo!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: logInView!.logo!, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        logInView!.logo!.frame = CGRectMake(logInView!.frame.width / 2 - 50, 60, 100, 100)
    }
}
