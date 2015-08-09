//
//  DonationHeaderTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import Mixpanel

protocol DonationHeaderCellDelegate: class {
    func showTimePickingDialogue(cell: DonationHeaderTableViewCell)
    func showDeclineDialogue(cell: DonationHeaderTableViewCell)
    func cancelDonation(cell: DonationHeaderTableViewCell)
    func completeDonation(cell: DonationHeaderTableViewCell)
    func showNeverPickedUpDialogue(cell: DonationHeaderTableViewCell)
}

class DonationHeaderTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var entityNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    @IBOutlet var acceptButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var foodDetailsLabel: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var managerNameLabel: UILabel!
    @IBOutlet weak var contactInfoTitle: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var OfferSentToTitle: UILabel!
    
    @IBOutlet weak var cancelDonationButton: UIButton!
    
    @IBOutlet weak var pickupCompleteLabel: UILabel!
    @IBOutlet weak var pickupCompleteYesButton: UIButton!
    @IBOutlet weak var pickupCompleteNoButton: UIButton!
    
    @IBOutlet weak var pendingOrgListLabel: UILabel!
    @IBOutlet weak var pendingOrgStatusesLabel: UILabel!
    
    weak var delegate: DonationHeaderCellDelegate?
    
    var pendingOffers: [PFObject]?
    
    var multiLineLabels:[UILabel!]?
    
    weak var donation: Donation! {
        didSet {
            if let donation = donation {
//                multiLineLabels = [timeLabel, statusLabel, foodDetailsLabel, locationButton.titleLabel, pendingOrgListLabel]
                
                hideDeclinedOptions(true)
                hidePickupTimePastOptions(true)
                
                // toggle hide and accept/decline stuff
                if let orgUser = (PFUser.currentUser() as? User)?.organization where donation.donationState == .Offered {
                    showAcceptAndDeclineButtons()
                } else {
                    hideAcceptAndDeclineButtons()
                }
                var entityName: String = "Today's donation offer"
                var managerName = ""
                
                var otherDonorUser: Donor?
                var otherOrgUser: Organization?
                if let donorUser = (PFUser.currentUser() as? User)?.donor {
                    hideLocation(true) // b/c donor doesn't need location
                    hideOffers(false) // b/c donation from donor's POV sometimes has an offers tab
                    
                    // if completed or accepted => show org's info
                    otherOrgUser = donation.toOrganization
                    if otherOrgUser != nil { // accepted or completed
                        entityName = otherOrgUser?["name"] as! String
                        managerName = otherOrgUser?["managerName"] as? String ?? ""
                        hideOffers(true)
                        hideContactInfo(false)
                        
                        if donation.donationState == .Accepted {
                            hidePickupTimePastOptions(donation.orgSpecificTime > NSDate()) // show if pickup date is in the past
                        }
                    } else { // declined or offered
                        hideContactInfo(true) // b/c there is no recipient's contact info to display yet
                        
                        // load pending org's statuses
                        if let pendingOffers = pendingOffers where pendingOffers.count > 0 {
                            pendingOrgListLabel.text = ""
                            pendingOrgStatusesLabel.text = ""
                            if pendingOffers.count < 1 {
                                pendingOrgListLabel.numberOfLines = 1
                                pendingOrgStatusesLabel.numberOfLines = 1
                            } else {
                                pendingOrgListLabel.numberOfLines = pendingOffers.count
                                pendingOrgStatusesLabel.numberOfLines = pendingOffers.count
                            }
                            
                            
                            for offer in pendingOffers {
                                pendingOrgListLabel.text! += "\(offer.objectForKey(ParseHelper.OfferConstants.toOrgProperty)!.objectForKey(ParseHelper.OrgConstants.nameProperty)!)\n"
                                pendingOrgStatusesLabel.text! += "\(offer[ParseHelper.OfferConstants.statusProperty]!)\n"
                            }
                        }
                        
                        if donation.donationState == .Declined { // declined
                            hideDeclinedOptions(false) // show options
                        }

                    }
                    
                } else if let orgUser = (PFUser.currentUser() as? User)?.organization {
                    otherDonorUser = donation.fromDonor
                    entityName = otherDonorUser?["name"] as! String
                    managerName = otherDonorUser?["managerName"] as? String ?? ""
                    hideOffers(true)
                    hideContactInfo(false)
                    
                    hideLocation(false)
                    hideContactInfo(false)
                    hideOffers(true)
                } // @ this point, either donor or org is nil, not both
                
                // update label text
                managerNameLabel.text = "\(managerName) - "
                entityNameLabel.text = entityName
                updateTimeLabel()
                
                statusLabel.text = donation.donationState.rawValue
                statusLabel.textColor = donation.stateToColor()
                foodDetailsLabel.text = donation.detailsString()
                
                if !phoneNumberButton.hidden {
                    // populate data depending on which otherUser is nil
                    let phoneNum = otherDonorUser?.phoneNumber ?? otherOrgUser?.phoneNumber
                    phoneNumberButton.setTitle(phoneNum, forState: .Normal)
                }
                
                locationButton.setTitle(donation.locationString(), forState: UIControlState.Normal)
                
            }
        }
    }
    
    func updateTimeLabel() {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        if let specificTime = donation.orgSpecificTime {
            timeLabel.text = formatter.stringFromDate(specificTime)
        } else {
            timeLabel.text = "\(formatter.stringFromDate(donation.donorTimeRangeStart!)) - \(formatter.stringFromDate(donation.donorTimeRangeEnd!))"
        }
    }
    
    @IBAction func cancelDonationTapped(sender: AnyObject) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "canceled", "donation state" : donation.donationState.rawValue])
        delegate?.cancelDonation(self)
    }
    
    @IBAction func acceptDonation(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "accept", "donation state" : donation.donationState.rawValue])
        delegate?.showTimePickingDialogue(self)
    }
    
    @IBAction func declineDonation(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "decline", "donation state" : donation.donationState.rawValue])
        delegate?.showDeclineDialogue(self)
    }
    
    @IBAction func completePickupTapped(sender: AnyObject) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "pickup completed", "donation state" : donation.donationState.rawValue])
        
        delegate?.completeDonation(self)
    }
    
    @IBAction func neverPickedUpTapped(sender: AnyObject) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "pickup never completed", "donation state" : donation.donationState.rawValue])
        delegate?.showNeverPickedUpDialogue(self)
    }
    
    private func showAcceptAndDeclineButtons() {
        declineButton.hidden = false
        acceptButton.hidden = false
        
        acceptButton.titleLabel!.font = UIFont(name: acceptButton.titleLabel!.font.fontName, size: 15.0)
        declineButton.titleLabel!.font = UIFont(name: declineButton.titleLabel!.font.fontName, size: 15.0)
    }
    
    private func hideAcceptAndDeclineButtons() {
        declineButton.hidden = true
        acceptButton.hidden = true
        
        acceptButton.titleLabel!.font = UIFont(name: acceptButton.titleLabel!.font.fontName, size: 0.0)
        declineButton.titleLabel!.font = UIFont(name: declineButton.titleLabel!.font.fontName, size: 0.0)
        
    }
    
    @IBAction func dialPhoneNumber(sender: AnyObject) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("existing donation", properties: ["action" : "dial phone number", "donation state" : donation.donationState.rawValue])
        
        if let button = sender as? UIButton {
            let oldPhone:String! = button.titleLabel?.text ?? ""
            
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
    }
    
    @IBAction func mapLocation(sender: UIButton) {
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
    
    /// Collapses or shows buttons or labels.
    private func setFontOfUIObject(object: AnyObject, normalFontSize: CGFloat, hidden: Bool) {
        if let button = object as? UIButton {
            button.hidden = hidden
            let fontSize: CGFloat = hidden ? 0.0 : normalFontSize
            button.titleLabel!.font = UIFont(name: button.titleLabel!.font.fontName, size: fontSize)
        } else if let label = object as? UILabel {
            label.hidden = hidden
            let fontSize: CGFloat = hidden ? 0.0 : normalFontSize
            label.font = UIFont(name: label.font.fontName, size: fontSize)
        }
    }
    
    /// Hides location title and button with address
    private func hideLocation(hidden: Bool) {
        setFontOfUIObject(locationTitle, normalFontSize: 14.0, hidden: hidden)
        setFontOfUIObject(locationButton, normalFontSize: 14.0, hidden: hidden)
    }
    
    /// Hides contact info title and button with phone number.
    private func hideContactInfo(hidden: Bool) {
        setFontOfUIObject(contactInfoTitle, normalFontSize: 14.0 , hidden: hidden)
        setFontOfUIObject(phoneNumberButton, normalFontSize: 14.0 , hidden: hidden)
        setFontOfUIObject(managerNameLabel, normalFontSize: 14.0 , hidden: hidden)
    }
    
    /// Hides buttons that appear when a donation is all declined (cancel and change recipient buttons)
    private func hideDeclinedOptions(hidden: Bool) {
        cancelDonationButton.hidden = hidden
    }
    
    /// Hides or shows two buttons that appear when a donation's pickup time has past.
    private func hidePickupTimePastOptions(hidden: Bool) {
        pickupCompleteYesButton.hidden = hidden
        pickupCompleteNoButton.hidden = hidden
        pickupCompleteLabel.hidden = hidden
    }
    
    /// Hides offers title label and two pending list labels (org names and statuses)
    private func hideOffers(hidden: Bool) {
        setFontOfUIObject(OfferSentToTitle, normalFontSize: 14.0, hidden: hidden)
        setFontOfUIObject(pendingOrgListLabel, normalFontSize: 12.0, hidden: hidden)
        setFontOfUIObject(pendingOrgStatusesLabel, normalFontSize: 12.0, hidden: hidden)
    }
    
}



































