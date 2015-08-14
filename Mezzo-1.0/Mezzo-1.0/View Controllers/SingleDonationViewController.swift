//
//  SingleDonationViewController.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 8/7/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class SingleDonationViewController: UIViewController {

    // MARK: outlets
    @IBOutlet weak var contentView: UIView!
    
    // status
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // action buttons
    @IBOutlet weak var firstSectionView: UIView!
    @IBOutlet weak var actionPromptLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var leftActionButton: UIButton?
    @IBOutlet weak var middleActionButton: UIButton?
    @IBOutlet weak var rightActionButton: UIButton?
    @IBOutlet weak var actionButtonsDivider: UIView!
    
    // donation details
    @IBOutlet weak var secondSectionView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var pickupNotesView: UIView!
    @IBOutlet weak var pickupNotesHeader: UILabel!
    @IBOutlet weak var pickupNotesLabel: UILabel!
    
    @IBOutlet weak var donationDetailsDivider: UIView!
    
    // offers
    @IBOutlet weak var offersView: UIView!
    @IBOutlet weak var offersHeader: UILabel!
    @IBOutlet weak var offersOrgLabel: UILabel!
    @IBOutlet weak var offersStatusLabel: UILabel!
    
    // contact info
    @IBOutlet weak var contactInfoView: UIView!
    @IBOutlet weak var thirdSectionView: UIView!
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
    
    // MARK: updating UI
    private func displayDonation(donation: Donation?) {
        if let donation = donation {
            var isDonor: Bool = false
            
            if let user = donorUser {
                isDonor = true
                displayOffers(donation.donationState, offers: self.pendingOffers)
            } else if let user = orgUser {
                isDonor = false
                if let offersView = offersView {
                    UIHelper.hideObjects([offersView])
                }
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
            if status == .Offered || status == .Declined || status == .Expired {
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
            statusView.backgroundColor = UIHelper.Colors.pendingOrangeAlpha
            statusLabel.textColor = UIHelper.Colors.pendingOrange
        case .Accepted:
            statusView.backgroundColor = UIHelper.Colors.acceptedGreenAlpha
            statusLabel.textColor = UIHelper.Colors.acceptedGreen
        case .Declined, .Expired:
            statusView.backgroundColor = UIHelper.Colors.declinedBrightRedAlpha
            statusLabel.textColor = UIHelper.Colors.declinedMutedRed
            statusView.backgroundColor = UIHelper.Colors.declinedMutedRed
        case .Completed:
            statusView.backgroundColor = UIHelper.Colors.completedGrayAlpha
            statusLabel.textColor = UIHelper.Colors.completedGray
        default:
            statusView.backgroundColor = UIHelper.Colors.completedGrayAlpha
            statusLabel.textColor = UIHelper.Colors.completedGray
        }
        
        statusStr.appendAttributedString(UIHelper.iconForStatus(status.rawValue, fontSize: 14.0, spacing: 0.0, colored: true))
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
            if button != nil {
                button!.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            }
        }
        
        switch status {
        case .Offered:
            if isDonor {
                UIHelper.hideObjects([firstSectionView])
            } else {
                UIHelper.hideObjects([actionPromptLabel, rightActionButton!])
                setButton(leftActionButton!, title: "Accept", action: "showAcceptDialogue", color: UIHelper.Colors.acceptedGreen, bold: true)
                setButton(middleActionButton!, title: "Decline", action: "showDeclineDialogue", color: UIHelper.Colors.completedGray, bold: false)
            }
        case .Accepted:
            if isDonor && donation.orgSpecificTime < NSDate() {
                UIHelper.hideObjects([rightActionButton!])
                setButton(leftActionButton!, title: "Yes", action: "showCompletedDialogue", color: UIHelper.Colors.acceptedGreen, bold: true)
                setButton(middleActionButton!, title: "No", action: "showIncompleteDialogue", color: UIHelper.Colors.completedGray, bold: false)
            } else {
                UIHelper.hideObjects([actionPromptLabel])
                setButton(leftActionButton!, title: "Call", action: "callButtonTapped", color: UIHelper.Colors.button, bold: false)
                setButton(middleActionButton!, title: "Email", action: "emailButtonTapped", color: UIHelper.Colors.button, bold: false)
                
                if !isDonor { UIHelper.hideObjects([rightActionButton!]) }
                else {
                    setButton(rightActionButton!, title: "Route", action: "routeButtonTapped", color: UIHelper.Colors.button, bold: false)
                }

            }
        case .Declined:
            if isDonor {
                UIHelper.hideObjects([middleActionButton!, rightActionButton!, actionPromptLabel!])
                setButton(leftActionButton!, title: "Cancel donation", action: "cancelDonationTapped", color: UIHelper.Colors.declinedMutedRed, bold: false)

            }
        case .Completed:
            UIHelper.hideObjects([firstSectionView])
        default:
            break
        }
    }
    
    private func displayDonationDetails(donation: Donation, isDonor: Bool) {
        if donation.donationState == .Offered || donation.donationState == .Declined {
            timeLabel.text = "\(formatDateToString(donation.donorTimeRangeEnd!))"
        } else {
            timeLabel.text = "\(formatDateToString(donation.orgSpecificTime!))"
        }
        
        displayFoodDetails(donation.foodDescription)
        sizeLabel.text = donation.size
        
        if !isDonor {
            if let instructions = donation.fromDonor?.specialInstructions {
                pickupNotesLabel.text = instructions
            }
        } else {
            if let pickup = pickupNotesView { UIHelper.hideObjects([pickup]) }
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
                UIHelper.hideObjects([offersView])
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
            UIHelper.hideObjects([contactInfoView])
        } else if isDonor { // show recipient's contact info
            let toOrg = donation.toOrganization
            phoneNumberTextView.text = toOrg?.phoneNumber ?? ""
            managerNameLabel.text = toOrg?.managerName ?? ""
            emailTextView.text = toOrg?.email ?? ""
            locationTextView.text = toOrg?.locationString ?? ""
            UIHelper.resizeTextView(locationTextView, heightConstraint: locationHeightConstraint)
        } else { // show donor's contact info
            let fromDonor = donation.fromDonor
            phoneNumberTextView.text = fromDonor?.phoneNumber ?? ""
            managerNameLabel.text = fromDonor?.managerName ?? ""
            emailTextView.text = fromDonor?.email ?? ""
            UIHelper.hideObjects([locationTextView, locationHeader])
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
        DonationActionsHelper.emailButtonTapped(self.donation, viewController: self)
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
    
    private func formatDateToString(date: NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.locale = NSLocale.currentLocale()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
    
    private func setButton(button: UIButton, title: String, action: String, color: UIColor, bold: Bool) {
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
        UIHelper.colorButtons([button], color: color, bold: bold)
    }
    
}

extension SingleDonationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
