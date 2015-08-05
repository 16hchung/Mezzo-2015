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
import MessageUI

class MezzoLoginViewController: PFLogInViewController {
    
    private var requestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add custom sign up button
        addRequestAccountButton()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // logo
        let logoView = UIImageView(image: UIImage(named: "Logo"))
        self.logInView!.logo = logoView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logInView!.logo!.frame = CGRectMake(logInView!.frame.width / 2 - 50, 60, 100, 100)
        addConstraintsToRequestButton()
    }
    
    private func addRequestAccountButton() {
        // create button
        requestButton = UIButton.buttonWithType(.Custom) as! UIButton
        requestButton.setTitle("Request an Account", forState: .Normal)
        let blueColor = UIColor(red: 0.349, green: 0.506, blue: 0.937, alpha: 1.000)
        requestButton.backgroundColor = blueColor
        requestButton.layer.cornerRadius = 5.0
        requestButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        requestButton.addTarget(self, action: "requestAccountButtonTapped:", forControlEvents: .TouchUpInside)
        
        // add underneath forgot password buttons
        self.logInView?.addSubview(requestButton)
    }
    
    private func addConstraintsToRequestButton() {
        // add constraints
        requestButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.logInView!,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0.0))
        
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.logInView!.passwordForgottenButton,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 20.0))
        
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
//            constant: 200.0))
            constant: self.logInView!.frame.width - 40.0))
        
        self.logInView?.addConstraint(NSLayoutConstraint(
            item: requestButton,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 50.0))
        
        self.logInView?.layoutIfNeeded()
    }
    
    func requestAccountButtonTapped(sender: AnyObject?) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["team.mezzo@gmail.com"])
        mailComposerVC.setSubject("Requesting an account")
        mailComposerVC.setMessageBody("Hello, \n\nMy name is [INSERT NAME HERE (eg. John Smith, Jane Doe)], and I'm involved with [NAME OF ORGANIZATION (eg. Whole Foods, Tri-City Volunteers)]. I'd like to join the Mezzo community, so that my organization can donate/accept surplus food. \n\n", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
}

extension MezzoLoginViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

























