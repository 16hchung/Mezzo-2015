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
    
    
    // MARK: colors
    struct Colors {
        static let buttonBlue = UIColor(red:0.392, green:0.710, blue:0.965, alpha:1.000)
        static let pendingOrange = UIColor(red:1.000, green:0.655, blue:0.149, alpha:1.000)
        static let acceptedGreen = UIColor(red: 0.332, green:0.824, blue:0.463, alpha:1.000)
        static let declinedBrightRed = UIColor(red:0.937, green:0.325, blue:0.314, alpha:1.000)
        static let completedGray = UIColor(white: 0.620, alpha: 1.000)
        static let declinedMutedRed = UIColor(red:0.898, green:0.451, blue:0.451, alpha:1.000)
    }
    
    // MARK: data
    var donation: Donation?
    var pendingOffers: [PFObject]?
    var donorUser: Donor?
    var orgUser: Organization?
    
    // MARK: view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let donor = (PFUser.currentUser() as? User)?.donor {
            self.donorUser = donor
        } else if let org = (PFUser.currentUser() as? User)?.organization {
            self.orgUser = org
        }

        
        testQuery { (result, error) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            } else {
                self.donation = result![1] as? Donation
                ParseHelper.getOffersForDonation(self.donation!, callBack: { (offers, error2) -> Void in
                    if let error = error2 {
                        ErrorHandling.defaultErrorHandler(error)
                    } else {
                        self.pendingOffers = offers as? [PFObject]
                        self.displayDonation(self.donation)
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func testQuery(callback: PFArrayResultBlock) {
        let query = Donation.query()
        query?.includeKey("fromDonor")
        query?.includeKey("toOrganization")
        
        query?.findObjectsInBackgroundWithBlock(callback)
    }
    
    // MARK: updating UI
    private func displayDonation(donation: Donation?) {
        if let donation = donation {
            if let user = donorUser {
                displayStatus(donation.donationState, isDonor: true)
                displayOffers(donation.donationState, offers: self.pendingOffers)
                displayContactInfo(donation, isDonor: true)
                displayActionButtons(donation, isDonor: true)
            } else if let user = orgUser {
                displayStatus(donation.donationState, isDonor: false)
                hideObjects([donationDetailsDivider, offersHeader, offersOrgLabel, offersStatusLabel])
                displayActionButtons(donation, isDonor: false)
                displayContactInfo(donation, isDonor: false)
            }
        }
    }
    
    private func displayNavTitle(donation: Donation, isDonor: Bool) {
        var navTitle: String!
        let status = donation.donationState
        
        if isDonor {
            if status == Donation.DonationState.Offered {
                navTitle = "Today's Offer"
            } else {
                let toOrg = donation.toOrganization!
                navTitle = toOrg["name"] as? String ?? ""
            }
        } else {
            let fromDonor = donation.fromDonor!
            navTitle = fromDonor["name"] as? String ?? ""
        }
        
        self.navigationItem.title = navTitle
    }
    
    private func displayStatus(status: Donation.DonationState, isDonor: Bool) {
        let rawStatus = status.rawValue
        
        switch status {
        case .Offered:
            statusLabel.text = isDonor ? "Pending acceptance" : "Awaiting your response"
            statusView.backgroundColor = Colors.pendingOrange
        case .Accepted:
            statusLabel.text = rawStatus
            statusView.backgroundColor = Colors.acceptedGreen
        case .Declined:
            statusLabel.text = rawStatus
            statusView.backgroundColor = Colors.declinedBrightRed
        case .Completed:
            statusLabel.text = rawStatus
            statusView.backgroundColor = Colors.completedGray
        default:
            statusLabel.text = rawStatus
            statusView.backgroundColor = Colors.completedGray
        }
    }
    
    private func displayActionButtons(donation: Donation, isDonor: Bool) {
        let status = donation.donationState
        
        switch status {
        case .Offered:
            if isDonor {
                hideObjects([actionButtonsDivider, leftActionButton, middleActionButton, rightActionButton, actionPromptLabel])
            } else {
                hideObjects([actionPromptLabel, rightActionButton])
                leftActionButton.setTitle("Accept", forState: .Normal)
                colorButtons([leftActionButton], color: Colors.acceptedGreen, bold: true)
                middleActionButton.setTitle("Decline", forState: .Normal)
                colorButtons([middleActionButton], color: Colors.declinedMutedRed, bold: false)
            }
        case .Accepted:
            if isDonor && donation.orgSpecificTime < NSDate() {
                hideObjects([rightActionButton])
                leftActionButton.setTitle("Yes", forState: .Normal)
                colorButtons([leftActionButton], color: Colors.acceptedGreen, bold: true)
                middleActionButton.setTitle("No", forState: .Normal)
                colorButtons([middleActionButton], color: Colors.declinedMutedRed, bold: false)
            } else {
                hideObjects([actionPromptLabel])
                leftActionButton.setTitle("Call", forState: .Normal)
                middleActionButton.setTitle("Email", forState: .Normal)
                rightActionButton.setTitle("Route", forState: .Normal)
                colorButtons([leftActionButton, middleActionButton, rightActionButton], color: Colors.buttonBlue, bold: false)
            }
        case .Declined:
            hideObjects([middleActionButton, rightActionButton, actionPromptLabel])
            leftActionButton.setTitle("Cancel donation", forState: .Normal)
            colorButtons([leftActionButton], color: Colors.declinedMutedRed, bold: false)
        case .Completed:
            hideObjects([actionButtonsDivider, leftActionButton, middleActionButton, rightActionButton, actionPromptLabel])
        default:
            break
        }
    }
    
    private func displayDonationDetails(donation: Donation) {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        if donation.donationState == .Offered {
            timeLabel.text = "\(formatter.stringFromDate(donation.donorTimeRangeStart!)) - \(formatter.stringFromDate(donation.donorTimeRangeEnd!))"
        } else {
            timeLabel.text = "\(formatter.stringFromDate(donation.orgSpecificTime!))"
        }
        
        displayFoodDetails(donation.foodDescription)
        sizeLabel.text = donation.size
    }
    
    private func displayFoodDetails(foods: [String]) {
        var foodsString: String!
        
        for food in foods {
            
        }
        
        foodLabel.text = foodsString
    }
    
    private func displayOffers(status: Donation.DonationState, offers: [PFObject]?) {
        if let offers = offers {
            if status == .Completed || status == .Accepted {
                hideObjects([offersHeader, offersOrgLabel, offersStatusLabel])
            } else {
                // TODO: display offers
            }
        }
    }
    
    private func displayContactInfo(donation: Donation, isDonor: Bool) {
        if isDonor && donation.donationState == .Offered {
            hideObjects([phoneNumberHeader, phoneNumberTextView, managerNameHeader, managerNameLabel,
                emailHeader, emailTextView, locationHeader, locationTextView])
        } else if isDonor { // show recipient's contact info
            let toOrg = donation.toOrganization
            phoneNumberTextView.text = toOrg?.phoneNumber ?? ""
            managerNameLabel.text = toOrg?.managerName ?? ""
            // TODO: add email field to org and donor tables
//            emailTextView.text = toOrg?.email ?? ""
            locationTextView.text = toOrg?.locationString ?? ""
            resizeTextView(locationTextView, heightConstraint: locationHeightConstraint)
        } else { // show donor's contact info
            let fromDonor = donation.fromDonor
            phoneNumberTextView.text = fromDonor?.phoneNumber ?? ""
            managerNameLabel.text = fromDonor?.managerName ?? ""
//            emailTextView.text = fromDonor?.email ?? ""
            locationTextView.text = fromDonor?.locationString ?? ""
            resizeTextView(locationTextView, heightConstraint: locationHeightConstraint)
        }
    }
    
    // MARK: helper functions
    private func hideObjects(objects: [AnyObject]) {
        for object in objects {
            object.removeFromSuperview()
            object.removeConstraints(object.constraints())
        }
    }
    
    private func colorButtons(buttons: [UIButton], color: UIColor, bold: Bool) {
        for button in buttons {
            button.layer.borderColor = color.CGColor
            button.layer.borderWidth = 2.0
            button.setTitleColor(color, forState: .Normal)
            if bold { button.titleLabel?.font = UIFont.boldSystemFontOfSize(19.0) }
        }
    }
    
//    private func iconForFood(food: String) -> NSMutableAttributedString {
//        switch food {
//        case "Grains/Beans":
//            return NSString(UTF8String: "\u{e604}") as! String + " "
//        case "Fruits/Veggies":
//            return NSString(UTF8String: "\u{e603}") as! String + " "
//        case "Meats":
//            return NSString(UTF8String: "\u{e605}") as! String + " "
//        case "Dairy":
//            return NSString(UTF8String: "\u{e602}") as! String + " "
//        case "Oils/Condiments":
//            return NSString(UTF8String: "\u{e601}") as! String + " "
//        case "Baked Goods":
//            return NSString(UTF8String: "\u{e600}") as! String + " "
//        default:
//            return NSString(UTF8String: "\u{e606}") as! String + " "
//        }
//        
//        foodLabel.font = UIFont(name: "FoodItems", size: 20)
//    }
    
    private func resizeTextView(textView: UITextView, heightConstraint: NSLayoutConstraint) {
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.max)).height
        heightConstraint.constant = height
    }
}
