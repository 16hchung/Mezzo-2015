//
//  SingleDonationViewController.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse

class SingleDonationViewController: UIViewController {

    // MARK: outlets
    @IBOutlet weak var contentView: UIView!
    
    // status
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // action buttons
    @IBOutlet weak var actionPromptLabel: UILabel!
    @IBOutlet weak var leftActionButton: UIButton!
    @IBOutlet weak var middleActionButton: UIButton!
    @IBOutlet weak var rightActionButton: UIButton!
    @IBOutlet weak var actionButtonsDivider: UIView!
    
    // donation details
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var pickupNotesHeader: UILabel!
    @IBOutlet weak var pickupNotesLabel: UILabel!
    
    @IBOutlet weak var donationDetailsDivider: UIView!
    
    // offers
    @IBOutlet weak var offersHeader: UILabel!
    @IBOutlet weak var offersOrgLabel: UILabel!
    @IBOutlet weak var offersStatusLabel: UILabel!
    
    // contact info
    @IBOutlet weak var phoneNumberHeader: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    @IBOutlet weak var managerNameHeader: UILabel!
    @IBOutlet weak var managerNameLabel: UILabel!
    @IBOutlet weak var emailHeader: UILabel!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var locationHeader: UILabel!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    
    // MARK: data
    var donation: Donation!
    var pendingOffers: [PFObject]?
    var donorUser: Donor?
    var orgUser: Organization?
    
    // MARK: view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func testQuery(callback: PFArrayResultBlock) {
        let query = Donation.query()!
        query.includeKey("fromDonor")
        query.includeKey("toOrganization")
        query.whereKey("objectId", equalTo: "AXqzIzDbY3")
        
        query.findObjectsInBackgroundWithBlock(callback)
    }
    
    // MARK: updating UI
    private func displayDonation(donation: Donation?) {
        if let donation = donation {
            var isDonor: Bool = false
            
            if let user = donorUser {
                isDonor = true
                displayOffers(donation.donationState, offers: self.pendingOffers)
            } else if let user = orgUser {
                isDonor = false
                UIHelper.hideObjects([donationDetailsDivider, offersHeader, offersOrgLabel, offersStatusLabel])
            }
            
            displayNavTitle(donation, isDonor: isDonor)
            displayStatus(donation.donationState, isDonor: isDonor)
            displayActionButtons(donation, isDonor: isDonor)
            displayDonationDetails(donation, isDonor: isDonor)
            displayContactInfo(donation, isDonor: isDonor)
        }
    }
    
    private func displayNavTitle(donation: Donation, isDonor: Bool) {
        var navTitle: String!
        let status = donation.donationState
        
        if isDonor {
            if status == .Offered || status == .Declined {
                navTitle = "Today's Offer"
            } else {
                let toOrg = donation.toOrganization!
                toOrg.fetchIfNeeded()
                navTitle = toOrg["name"] as? String ?? ""
            }
        } else {
            let fromDonor = donation.fromDonor!
            fromDonor.fetchIfNeeded()
            navTitle = fromDonor["name"] as? String ?? ""
        }
        
        self.navigationItem.title = navTitle
    }
    
    private func displayStatus(status: Donation.DonationState, isDonor: Bool) {
        let rawStatus = status.rawValue
        var statusStr = NSMutableAttributedString(string: "")
        
        switch status {
        case .Offered:
            statusView.backgroundColor = UIHelper.Colors.pendingOrange
        case .Accepted:
            statusView.backgroundColor = UIHelper.Colors.acceptedGreen
        case .Declined:
            statusView.backgroundColor = UIHelper.Colors.declinedBrightRed
        case .Completed:
            statusView.backgroundColor = UIHelper.Colors.completedGray
        default:
            statusView.backgroundColor = UIHelper.Colors.completedGray
        }
        
        statusStr.appendAttributedString(UIHelper.iconForStatus(status.rawValue, fontSize: 14.0, spacing: 0.0, colored: false))
        if status == .Offered {
            statusStr.appendAttributedString(NSMutableAttributedString(string: isDonor ? "  Pending acceptance" : "  Awaiting your response"))
        } else {
            statusStr.appendAttributedString(NSMutableAttributedString(string: "  \(rawStatus)"))
        }
        statusLabel.attributedText = statusStr
    }
    
    private func displayActionButtons(donation: Donation, isDonor: Bool) {
        let status = donation.donationState
        
        // clear all targets from all buttons (b/c we'll be reassigning them)
        for button in [leftActionButton, middleActionButton, rightActionButton] {
            button.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        }
        
        switch status {
        case .Offered:
            if isDonor {
                UIHelper.hideObjects([actionButtonsDivider, leftActionButton, middleActionButton, rightActionButton, actionPromptLabel])
            } else {
                UIHelper.hideObjects([actionPromptLabel, rightActionButton])
                leftActionButton.setTitle("Accept", forState: .Normal)
                leftActionButton.addTarget(self, action: "showAcceptDialogue", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([leftActionButton], color: UIHelper.Colors.acceptedGreen, bold: true)
                middleActionButton.setTitle("Decline", forState: .Normal)
                middleActionButton.addTarget(self, action: "showDeclineDialogue", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([middleActionButton], color: UIHelper.Colors.declinedMutedRed, bold: false)
            }
        case .Accepted:
            if isDonor && donation.orgSpecificTime < NSDate() {
                UIHelper.hideObjects([rightActionButton])
                leftActionButton.setTitle("Yes", forState: .Normal)
                leftActionButton.addTarget(self, action: "showCompletedDialogue", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([leftActionButton], color: UIHelper.Colors.acceptedGreen, bold: true)
                middleActionButton.setTitle("No", forState: .Normal)
                middleActionButton.addTarget(self, action: "showIncompleteDialogue", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([middleActionButton], color: UIHelper.Colors.declinedMutedRed, bold: false)
            } else {
                UIHelper.hideObjects([actionPromptLabel])
                leftActionButton.setTitle("Call", forState: .Normal)
                leftActionButton.addTarget(self, action: "callButtonTapped", forControlEvents: .TouchUpInside)
                middleActionButton.setTitle("Email", forState: .Normal)
                middleActionButton.addTarget(self, action: "emailButtonTapped", forControlEvents: .TouchUpInside)
                rightActionButton.setTitle("Route", forState: .Normal)
                rightActionButton.addTarget(self, action: "routeButtonTapped", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([leftActionButton, middleActionButton, rightActionButton], color: UIHelper.Colors.buttonBlue, bold: false)
            }
        case .Declined:
            if isDonor {
                UIHelper.hideObjects([middleActionButton, rightActionButton, actionPromptLabel])
                leftActionButton.setTitle("Cancel donation", forState: .Normal)
                leftActionButton.addTarget(self, action: "cancelDonationTapped", forControlEvents: .TouchUpInside)
                UIHelper.colorButtons([leftActionButton], color: UIHelper.Colors.declinedMutedRed, bold: false)
            }
        case .Completed:
            UIHelper.hideObjects([actionButtonsDivider, leftActionButton, middleActionButton, rightActionButton, actionPromptLabel])
        default:
            break
        }
    }
    
    private func displayDonationDetails(donation: Donation, isDonor: Bool) {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        if donation.donationState == .Offered || donation.donationState == .Declined {
            timeLabel.text = "\(formatter.stringFromDate(donation.donorTimeRangeStart!)) - \(formatter.stringFromDate(donation.donorTimeRangeEnd!))"
        } else {
            timeLabel.text = "\(formatter.stringFromDate(donation.orgSpecificTime!))"
        }
        
        displayFoodDetails(donation.foodDescription)
        sizeLabel.text = donation.size
        
        if !isDonor {
            if let instructions = donation.fromDonor?.specialInstructions {
                pickupNotesLabel.text = instructions
            }
        } else {
            UIHelper.hideObjects([pickupNotesHeader, pickupNotesLabel])
        }
    }
    
    private func displayFoodDetails(foods: [String]) {
        var foodsString = NSMutableAttributedString(string: "")
        
        for food in foods {
            foodsString.appendAttributedString(UIHelper.iconForFood(food, fontSize: 20, color: UIColor.blackColor()))
            foodsString.appendAttributedString(NSMutableAttributedString(string: "\(food)"))
            if food != foods.last { foodsString.appendAttributedString(NSMutableAttributedString(string: "\n")) }
        }
        
        foodLabel.attributedText = foodsString
    }
    
    private func displayOffers(status: Donation.DonationState, offers: [PFObject]?) {
        if let offers = offers where offers.count > 0 {
            if status == .Completed || status == .Accepted {
                UIHelper.hideObjects([offersHeader, offersOrgLabel, offersStatusLabel])
            } else {
                offersOrgLabel.numberOfLines = offers.count
                offersOrgLabel.text = ""
                offersStatusLabel.numberOfLines = offers.count
                offersStatusLabel.text = ""
                
                var orgStr = ""
                var statusStr = NSMutableAttributedString(string: "")
                
                for offer in offers {
                    orgStr += "\((offer.objectForKey(ParseHelper.OfferConstants.toOrgProperty) as? Organization)!.name)" ?? ""
                    statusStr.appendAttributedString(UIHelper.iconForStatus(offer["status"] as? String ?? "", fontSize: 17.0, spacing: 5, colored: true))
                    if offer != offers.last {
                        orgStr += "\n"
                        statusStr.appendAttributedString(NSMutableAttributedString(string: "\n"))
                    }
                }
                
                offersStatusLabel.attributedText = statusStr
                var orgSpacing = NSMutableParagraphStyle()
                orgSpacing.lineSpacing = 4
                offersOrgLabel.attributedText = NSMutableAttributedString(string: orgStr, attributes: [NSParagraphStyleAttributeName: orgSpacing])
            }
        }
    }
    
    private func displayContactInfo(donation: Donation, isDonor: Bool) {
        if isDonor && (donation.donationState == .Offered || donation.donationState == .Declined) {
            UIHelper.hideObjects([phoneNumberHeader, phoneNumberTextView, managerNameHeader, managerNameLabel,
                emailHeader, emailTextView, locationHeader, locationTextView])
        } else if isDonor { // show recipient's contact info
            let toOrg = donation.toOrganization
            phoneNumberTextView.text = toOrg?.phoneNumber ?? ""
            managerNameLabel.text = toOrg?.managerName ?? ""
            // TODO: add email field to org and donor tables
//            emailTextView.text = toOrg?.email ?? ""
            locationTextView.text = toOrg?.locationString ?? ""
            UIHelper.resizeTextView(locationTextView, heightConstraint: locationHeightConstraint)
        } else { // show donor's contact info
            let fromDonor = donation.fromDonor
            phoneNumberTextView.text = fromDonor?.phoneNumber ?? ""
            managerNameLabel.text = fromDonor?.managerName ?? ""
//            emailTextView.text = fromDonor?.email ?? ""
            locationTextView.text = fromDonor?.locationString ?? ""
            UIHelper.resizeTextView(locationTextView, heightConstraint: locationHeightConstraint)
        }
    }
    
    // MARK: button targets
    
    func cancelDonationTapped() {
        DonationActionsHelper.cancelDonationTapped(self.donation!, refreshCallback: { (obj) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    func callButtonTapped() {
        DonationActionsHelper.callButtonTapped(self.donation)
    }
    
    func emailButtonTapped() {
        DonationActionsHelper.emailButtonTapped(self.donation)
    }
    
    func routeButtonTapped() {
        DonationActionsHelper.routeButtonTapped(self.donation)
    }
    
    func showCompletedDialogue() {
        DonationActionsHelper.showCompletedDialogue(self.donation, viewController: self) { (obj) -> Void in
            self.refreshDonation()
        }
    }
    
    func showIncompleteDialogue() {
        DonationActionsHelper.showIncompleteDialogue(self.donation, viewController: self) { (obj) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func showAcceptDialogue() {
        DonationActionsHelper.showAcceptDialogue(self.donation, viewController: self) { (obj) -> Void in
            self.refreshDonation()
        }
    }
    
    func showDeclineDialogue() {
        DonationActionsHelper.showDeclineDialogue(self.donation, viewController: self) { (obj) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    // MARK: helper methods
    
    private func reloadUI() {
        if let donor = (PFUser.currentUser() as? User)?.donor {
            self.donorUser = donor
            if let toOrg = self.donation?.toOrganization {
                toOrg.fetchIfNeededInBackground()
            }
        } else if let org = (PFUser.currentUser() as? User)?.organization {
            self.orgUser = org
            if let fromDonor = self.donation?.fromDonor {
                fromDonor.fetchIfNeededInBackground()
            }
        }
        
        displayDonation(self.donation)
    }
    
    private func refreshDonation() {
        ParseHelper.getUpdatedDonationFor(self.donation!, callback: { (result, error) -> Void in
            if let error = error { ErrorHandling.defaultErrorHandler(error) }
            else {
                self.donation = result![0] as! Donation
                self.reloadUI()
            }
        })
    }
    
    
}
