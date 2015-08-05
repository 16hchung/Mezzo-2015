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
        
        // add custom sign up button
        addRequestAccountButton()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // logo
        let logoView = UIImageView(image: UIImage(named: "Logo"))
        self.logInView!.logo = logoView
        
        // sign up button
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logInView!.logo!.frame = CGRectMake(logInView!.frame.width / 2 - 50, 60, 100, 100)
    }
    
    private func addRequestAccountButton() {
        // create button
        let requestButton: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        requestButton.setTitle("Request an Account", forState: .Normal)
        requestButton.backgroundColor = UIColor.blueColor()
        requestButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        requestButton.frame = CGRectMake(100, 100, 100, 50)
        requestButton.addTarget(self, action: "requestAccountButtonTapped:", forControlEvents: .TouchUpInside)
        
        // add underneath forgot password buttons
        self.logInView?.addSubview(requestButton)
        
        // add constraints
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.logInView!,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0))
        
//        self.logInView?.addConstraint(NSLayoutConstraint(
//            item: requestButton,
//            attribute: .Top,
//            relatedBy: .Equal,
//            toItem: self.logInView?.passwordForgottenButton,
//            attribute: .Bottom,
//            multiplier: 1.0,
//            constant: 30.0))

        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 48.0))
        
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 32.0))
        
        self.logInView?.layoutIfNeeded()
    }
    
    func requestAccountButtonTapped(sender: AnyObject?) {
        println("yay you tapped me")
    }
}
