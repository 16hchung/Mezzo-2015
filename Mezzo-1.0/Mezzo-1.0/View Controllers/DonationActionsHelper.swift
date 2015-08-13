//
//  DonationActionsHelper.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 8/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import RMDateSelectionViewController
import RMActionController
import Mixpanel

typealias RefreshVC = (AnyObject?) -> Void

class DonationActionsHelper {
    static func showAcceptDialogue(donation: Donation, viewController: UIViewController, refreshCallback: RefreshVC) {
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Done) { controller -> Void in
            if let controller = controller as? RMDateSelectionViewController {
                ParseHelper.respondToOfferForDonation(donation, withTime: controller.datePicker.date, byAccepting: true) { success, error -> Void in
                    if let error = error { ErrorHandling.defaultErrorHandler(error) }
                    refreshCallback(nil)
                }
            }
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { controller -> Void in }
        
        let controller = RMDateSelectionViewController(style: RMActionControllerStyle.White, title: "Pickup Time", message: "I can pick up the donation at:", selectAction: selectAction, andCancelAction: cancelAction)
        
        //        controller.datePicker.minimumDate = cell.donation.donorTimeRangeStart
        controller.datePicker.minimumDate = NSDate()
        controller.datePicker.maximumDate = donation.donorTimeRangeEnd
        
        viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    static func showDeclineDialogue(donation: Donation, viewController: UIViewController, refreshCallback: RefreshVC) {
        let alertController = UIAlertController(title: nil, message: "Decline this donation offer?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            ParseHelper.respondToOfferForDonation(donation, withTime: nil, byAccepting: false) { success, error -> Void in
                if let error = error { ErrorHandling.defaultErrorHandler(error) }
                refreshCallback(nil)
            }
        }
        alertController.addAction(yesAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func showCompletedDialogue(donation: Donation, viewController: UIViewController, refreshCallback: RefreshVC) {
        let alertController = UIAlertController(title: "Donation complete", message: "Confirming that \(donation.toOrganization!.name) picked up this donation?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            donation.setDonationState(.Completed) { (success, error) -> Void in
                if let error = error { ErrorHandling.defaultErrorHandler(error) }
                refreshCallback(nil)
            }
        }
        alertController.addAction(yesAction)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Shown when a donor indicates that a donation was never picked up.
    static func showIncompleteDialogue(donation: Donation, viewController: UIViewController, refreshCallback: RefreshVC) {
        var explanationTextField: UITextField?
        
        let alertView = UIAlertController(title: "Incomplete donation", message: "Please briefly explain why this donation was never picked up by \(donation.toOrganization!.name).", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertView.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { (action) -> Void in
            println(explanationTextField!.text)
            donation.setDonationState(.Incomplete, callback: { (success, error) -> Void in
                if let error = error { ErrorHandling.defaultErrorHandler(error) }
                refreshCallback(nil)
            })
        }
        alertView.addAction(submitAction)
        
        alertView.addTextFieldWithConfigurationHandler { (textField) -> Void in
            explanationTextField = textField
            explanationTextField?.placeholder = "Explain here"
        }
        
        viewController.presentViewController(alertView, animated: true, completion: nil)
    }
    
    static func cancelDonationTapped(donation: Donation, refreshCallback: RefreshVC) {
        donation.setDonationState(.Cancelled, callback: { (success, error) -> Void in
            if let error = error { ErrorHandling.defaultErrorHandler(error) }
            refreshCallback(nil)
        })
    }
    
    static func callButtonTapped(donation: Donation) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "dial phone number", "donation state" : donation.donationState.rawValue])

        
        var oldPhone = ""
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            oldPhone = donation.fromDonor!.phoneNumber
        } else if let donorUser = (PFUser.currentUser() as? User)?.donor {
            oldPhone = donation.toOrganization!.phoneNumber
        }
        
        var newPhone = ""
        
        for index in oldPhone.startIndex..<oldPhone.endIndex{
            let charAtIndex = oldPhone[index]
            
            switch charAtIndex {
            case "0","1","2","3","4","5","6","7","8","9":
                newPhone = newPhone + String(charAtIndex)
            default:
                break
            }
        }
        
        if let url = NSURL(string: "tel://\(newPhone)") {
            UIApplication.sharedApplication().openURL(url)
        }

    }
    
    static func emailButtonTapped(donation: Donation) {
        
    }
    
    static func routeButtonTapped(donation: Donation) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "see location", "donation state" : donation.donationState.rawValue])
        
        let location = donation.location()
        
        if let lat = location.latitude, long = location.longitude {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!) {
                let searchable = donation.locationString().stringByReplacingOccurrencesOfString(" ", withString: "+")
                UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?q=\(searchable)&center=\(lat),\(long)&zoom=14")!)
            } else {
                // go to apple maps
            }
        }
    }
}