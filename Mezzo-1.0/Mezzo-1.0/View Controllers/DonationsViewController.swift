//
//  DonationsViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/8/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse
import RMDateSelectionViewController
import RMActionController
import Mixpanel

class DonationsViewController: UIViewController {
    
    // MARK: Outlets
    
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var emptyStateButton: UIButton!
    @IBOutlet weak var loadingView: UIView!

    // MARK: Properties
    
    var noUpcomingDonations: Bool = false
    var donations = [Donation : [PFObject]]()
    var orderedDonationKeys: [Donation] {
        get { // TODO: add canceled?
            var donationsToReturn = [Donation]()
            
            var allSortedKeys = donations.keys.array
            allSortedKeys.sort {
                if $0.donationState == .Accepted && $1.donationState == .Accepted {
                    return $0.orgSpecificTime < $1.orgSpecificTime
                } else if $0.donationState == .Completed && $1.donationState == .Completed {
                    return $0.orgSpecificTime > $1.orgSpecificTime
                } else {
                    return $0.updatedAt > $1.updatedAt
                }
            }
            
            // states array ordered based on order we want in tableView
            for donationState: Donation.DonationState in [.Declined, .Offered, .Accepted, .Completed] {
                donationsToReturn += allSortedKeys.filter{ $0.donationState == donationState }
            }
            
            return donationsToReturn
        }
    }
    
//    // search bar modes
//    private enum SearchBarState {
//        case DefaultMode
//        case SearchMode
//    }
//
//    private var searchBarState: SearchBarState = .DefaultMode {
//        didSet {
//            switch(searchBarState) {
//            case .DefaultMode:
//                searchBar.resignFirstResponder()
//                searchBar.text = ""
//                searchBar.showsCancelButton = false
//            case .SearchMode:
//                let searchText = searchBar.text ?? ""
//                searchBar.showsCancelButton = true
//                // donations = searchDonations(searchText)
//            }
//        }
//    }
    
    // segmented control modes
    private let UPCOMING: Int  = 0
    private let COMPLETED: Int = 1
    
    
    /// pull to refresh 
    // lazy b/c doesn't need to be created immediately
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing your donations...")
        return refreshControl
    }()
    
    @IBAction func settingsButtonSelected(sender: UIBarButtonItem) {
        if let orgUser = (PFUser.currentUser() as? User)?.organization {
            performSegueWithIdentifier("Org Settings", sender: nil)
        } else {
            performSegueWithIdentifier("Donor Settings", sender: nil)
        }
    }
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting delegate + datasource
        tableView.delegate = self
        tableView.dataSource = self
//        searchBar.delegate = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        segmentedControl.selectedSegmentIndex = UPCOMING
        reloadUpcomingDonationsData()
        
        // adds listener to reload table view data every time the app comes back into the foreground
        // (ex user goes to home screen and comes back to the app without quitting)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotification", object: nil)
        
        // pull to refresh setup
        self.tableView.addSubview(refreshControl)
        
//        searchBarState = .DefaultMode
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        segmentedControl.selectedSegmentIndex = UPCOMING
        reloadUpcomingDonationsData()
    }
    
    func pushNotificationReceived(notification: NSNotification) {
        segmentedControlChanged(nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // remove listener for foreground when the user navigates away from the table view
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: reload donations data
    
    private func reloadUpcomingDonationsData() {
        loadingView.hidden = false
        
        var loadingDonations: [Donation : [PFObject]] = [:]
        
        // load donations (getDonations already deals with type of user)
        if let donorUser = (PFUser.currentUser() as! User).donor {
            ParseHelper.getUpcomingDonationsForDonor(donorUser: donorUser) { (result: [AnyObject]?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                    
                } else if var loadedDonations = result as? [Donation] {
                    for donation in loadedDonations {
                        loadingDonations[donation] = []
                    }
                    
                    // filter donations that need to display their offers
                    loadedDonations.filter { $0.donationState == .Offered || $0.donationState == .Declined }
                    if loadedDonations.isEmpty {
                        self.donations = loadingDonations
                        self.noUpcomingDonations = (self.donations.count == 0)
                        self.reloadUI()
                    } else {
                        for donation in loadedDonations {
                            ParseHelper.getOffersForDonation(donation) { (result: [AnyObject]?, error: NSError?) -> Void in
                                if let error = error {
                                    ErrorHandling.defaultErrorHandler(error)
                                    
                                } else if let loadedOffers = result as? [PFObject] {
                                    loadingDonations[donation] = loadedOffers
                                    
                                    if donation == loadedDonations.last { // reload UI once the offers for all the donatoins have been loaded
                                        self.donations = loadingDonations
                                        self.noUpcomingDonations = (self.donations.count == 0)
                                        self.reloadUI()
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        } else if let orgUser = (PFUser.currentUser() as! User).organization {
            // load pending donation offers first
            ParseHelper.getUpcomingDonationsForRecipient(orgUser: orgUser, isPending: true) { (result: [AnyObject]?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                    
                } else if let pendingOffers = result as? [PFObject] {
                    
                    var pendingDonations:[Donation] = [Donation]()
                    
                    for offer in pendingOffers {
                        let donation = offer.objectForKey(ParseHelper.OfferConstants.donationProperty) as! Donation
                        pendingDonations.append(donation)
                    }
                    
                    // then load any accepted donations
                    ParseHelper.getUpcomingDonationsForRecipient(orgUser: orgUser, isPending: false) { (result: [AnyObject]?, error: NSError?) -> Void in
                        if let error = error {
                            ErrorHandling.defaultErrorHandler(error)
                            
                        } else if var acceptedDonations = result as? [Donation] {
                            for donation in pendingDonations + acceptedDonations {
                                loadingDonations[donation] = []
                            }
                            self.donations = loadingDonations
                            self.noUpcomingDonations = (self.donations.count == 0)
                            self.reloadUI()
                        }
                    }
                }
            }
        }
    }
    
    private func reloadCompletedDonationsData() {
        var loadingDonations: [Donation : [PFObject]] = [:]
        
        loadingView.hidden = false
        
        ParseHelper.getCompletedDonations() { (result: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
                
            } else if let loadedDonations = result as? [Donation] {
                for donation in loadedDonations {
                    loadingDonations[donation] = []
                }
                self.donations = loadingDonations
                self.reloadUI()
            }
            
        }
    }
    
    
    @IBAction func segmentedControlChanged(sender: AnyObject?) {
        let mixpanel = Mixpanel.sharedInstance()
        switch segmentedControl.selectedSegmentIndex {
        case UPCOMING:
            reloadUpcomingDonationsData()
            if sender != nil {
                mixpanel.track("all donations", properties: ["action" : "segmented control to upcoming"])
            }
        case COMPLETED:
            reloadCompletedDonationsData()
            if sender != nil {
                mixpanel.track("all donations", properties: ["action" : "segmented control to completed"])
            }
        default:
            reloadUpcomingDonationsData()
        }
    }
    
    // MARK: pull to refresh
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        switch segmentedControl.selectedSegmentIndex {
        case UPCOMING:
            reloadUpcomingDonationsData()
        case COMPLETED:
            reloadCompletedDonationsData()
        default:
            reloadUpcomingDonationsData()
        }
        
//        refreshControl.endRefreshing()
    }
    
    // MARK: update UI after data has been loaded
    
    private func reloadUI() {
        // load the appropriate empty state button if necessary
        self.updateNoDonationsButton()
        
        // do the add button thing
        if let user = PFUser.currentUser()! as? User where user.donor != nil {
            navigationItem.rightBarButtonItem = self.addBarButton
            
            // in production mode, donors can't add two donations at once
            // in debug mode, donors can add more than one donation (for ease of testing)
            if (debugMode) {
                navigationItem.rightBarButtonItem?.enabled = true
            } else {
                if !noUpcomingDonations { navigationItem.rightBarButtonItem?.enabled = false }
                else { navigationItem.rightBarButtonItem?.enabled = true }
            }
        } else if let user = PFUser.currentUser()! as? User where user.organization != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.reloadData()
        
        refreshControl.endRefreshing()
        // refreshing bool
        loadingView.hidden = true
    }
    
    private func updateNoDonationsButton() {
        if donations.count == 0 {
            emptyStateButton.hidden = false
            emptyStateButton.enabled = true
            emptyStateButton.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 1)
            
            emptyStateButton.titleLabel?.numberOfLines = 0
            emptyStateButton.titleLabel?.textAlignment = .Center
            emptyStateButton.titleLabel?.textColor = UIColor.grayColor()
            
            if (segmentedControl.selectedSegmentIndex == COMPLETED) {
                let headline = "No donations completed!"
                let text = NSMutableAttributedString(string: "\(headline)")
                text.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 20.0)!, range: NSRange(location: 0, length: count(headline)))
                emptyStateButton.setAttributedTitle(text, forState: .Normal)
                emptyStateButton.enabled = false
            } else {
                if let user = PFUser.currentUser()! as? User where user.donor != nil {
                    let headline = "No donations yet!"
                    let text = NSMutableAttributedString(string: "\(headline)")
                    text.appendAttributedString(NSAttributedString(string: "\n"))
                    text.appendAttributedString(NSAttributedString(string: "\n"))
                    text.appendAttributedString(NSAttributedString(string: "Tap the + button in the top right to create a new donation offer."))
                    
                    text.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 20.0)!, range: NSRange(location: 0, length: count(headline)))
                    emptyStateButton.setAttributedTitle(text, forState: .Normal)
                    
                } else if let user = PFUser.currentUser()! as? User where user.organization != nil {
                    emptyStateButton.enabled = false
                    
                    let headline = "No donations yet!"
                    let text = NSMutableAttributedString(string: "\(headline)")
                    text.appendAttributedString(NSAttributedString(string: "\n"))
                    text.appendAttributedString(NSAttributedString(string: "\n"))
                    text.appendAttributedString(NSAttributedString(string: "We will notify you when a new donation offer comes in."))
                    
                    text.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 20.0)!, range: NSRange(location: 0, length: count(headline)))
                    emptyStateButton.setAttributedTitle(text, forState: .Normal)
                    
                    // TODO: redirect to settings page in the future?
                }
            }
        } else {
            emptyStateButton.enabled = false
            emptyStateButton.hidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Navigation
    
    @IBAction func unwindToDonationsVC(sender: UIStoryboardSegue) {
        if let identifier = sender.identifier {
            switch identifier {
            case "Send Offer":
                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.track("next", properties: ["from screen": "new donation who", "action": "offer"])
                
                let source = sender.sourceViewController as! OrganizationChooserViewController
                
                source.donation.offer ((PFUser.currentUser()! as! User).donor!, toOrgs: source.selectedRecipientOrganizations)   { (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                        
                    } else {
                        for org in source.selectedRecipientOrganizations {
                            ParseHelper.addOfferToDonation(source.donation, toOrganization: org) { (success, error) -> Void in
                                println("yay finished with the callback")
                                if let error = error {
                                    ErrorHandling.defaultErrorHandler(error)
                                } else {
                                    self.segmentedControlChanged(nil)
                                }
                            }
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindFromMyInfo(sender: UIStoryboardSegue) {
        switch sender.identifier! {
        case "Save my info":
            break
//            println("saving my info")
        default:
            break
        }
    }
}

// MARK: - Table View Data Source Protocol

extension DonationsViewController: UITableViewDataSource {
    
    // MARK: Cells
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return donations.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let donation = orderedDonationKeys[section]
        if let donorUser = (PFUser.currentUser() as? User)?.donor where donation.donationState == .Offered {
            return 1
        } else {
            return 2
        }
    }
    
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let donation = orderedDonationKeys[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Donation Header", forIndexPath: indexPath) as! DonationTableViewCell
            cell.donation = donation
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        } else {
            if let donorUser = (PFUser.currentUser() as? User)?.donor {
                switch donation.donationState {
                case .Accepted:
                    if donation.orgSpecificTime > NSDate() {
                        let cell = tableView.dequeueReusableCellWithIdentifier("Contact Options", forIndexPath: indexPath) as! ContactActionsTableViewCell
                        cell.donation = donation
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCellWithIdentifier("Pickup Confirmation", forIndexPath: indexPath) as! PickupConfirmationTableViewCell
                        cell.delegate = self
                        cell.donation = donation
                        return cell
                    }
                case .Declined:
                    let cell = tableView.dequeueReusableCellWithIdentifier("Cancel Option", forIndexPath: indexPath) as! CancelTableViewCell
                    cell.donation = donation
                    cell.delegate = self
                    return cell
                default:
                    break
                }
            } else {
                switch donation.donationState {
                case .Accepted:
                    let cell = tableView.dequeueReusableCellWithIdentifier("Contact Options", forIndexPath: indexPath) as! ContactActionsTableViewCell
                    cell.donation = donation
                    return cell
                case .Offered:
                    let cell = tableView.dequeueReusableCellWithIdentifier("Pending Org Options", forIndexPath: indexPath) as! OrgOfferedActionsTableViewCell
                    cell.donation = donation
                    cell.delegate = self
                    return cell
                default:
                    break
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - Table View Delegate Protocol

extension DonationsViewController: UITableViewDelegate {
    
}

// MARK: - Search Bar Delegate

//extension DonationsViewController: UISearchBarDelegate {
//    // user begins editing the search text
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        self.searchBarState = .SearchMode
//    }
//    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchBarState = .DefaultMode
//    }
//    
//    // user changed the search text, so filter through notes and update view
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        // TODO: search for the given donor
//        // donations = searchDonations(searchText)
//    }
//}

extension DonationsViewController: PendingOrgActionsCellDelegate {
    
    func showTimePickingDialogue(cell: OrgOfferedActionsTableViewCell) {
        
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Done) { controller -> Void in
            if let controller = controller as? RMDateSelectionViewController {
                ParseHelper.respondToOfferForDonation(cell.donation, withTime: controller.datePicker.date, byAccepting: true) { success, error -> Void in
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                        
                    }
                    
                    self.reloadUpcomingDonationsData()
                }
            }
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { controller -> Void in }
        
        let controller = RMDateSelectionViewController(style: RMActionControllerStyle.White, title: "Pickup Time", message: "I can pick up the donation at:", selectAction: selectAction, andCancelAction: cancelAction)
        
        controller.datePicker.minimumDate = cell.donation.donorTimeRangeStart
        controller.datePicker.maximumDate = cell.donation.donorTimeRangeEnd
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func showDeclineDialogue(cell: OrgOfferedActionsTableViewCell) {
        
        let alertController = UIAlertController(title: nil, message: "Decline this donation offer?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            ParseHelper.respondToOfferForDonation(cell.donation, withTime: nil, byAccepting: false) { success, error -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                    
                }
                self.reloadUpcomingDonationsData()
            }
        }
        alertController.addAction(yesAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}

extension DonationsViewController: CancelCellDelegate {

    func cancelDonation(cell: CancelTableViewCell) {
        cell.donation.setDonationState(.Cancelled) { (success, error) -> Void in
            if let error = error { ErrorHandling.defaultErrorHandler(error) }
            self.segmentedControlChanged(nil)
        }
    }
}

extension DonationsViewController: PickupConfirmationCellDelegate {

    func completeDonation(cell: PickupConfirmationTableViewCell) {
        let alertController = UIAlertController(title: "Donation complete", message: "Confirming that \(cell.donation.toOrganization!.name) picked up this donation?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            cell.donation.setDonationState(.Completed) { (success, error) -> Void in
                if let error = error { ErrorHandling.defaultErrorHandler(error) }
                self.segmentedControlChanged(nil)
            }
        }
        alertController.addAction(yesAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showNeverPickedUpDialogue(cell: PickupConfirmationTableViewCell) {
        var explanationTextField: UITextField?
        
        let alertView = UIAlertController(title: "Incomplete donation", message: "Please briefly explain why this donation was never picked up by \(cell.donation.toOrganization!.name).", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertView.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { (action) -> Void in
            println(explanationTextField!.text)
            cell.donation.setDonationState(.Incomplete, callback: { (success, error) -> Void in
                if let error = error { ErrorHandling.defaultErrorHandler(error) }
                self.segmentedControlChanged(nil)
            })
        }
        alertView.addAction(submitAction)
        
        alertView.addTextFieldWithConfigurationHandler { (textField) -> Void in
            explanationTextField = textField
            explanationTextField?.placeholder = "Explain here"
        }
        
        presentViewController(alertView, animated: true, completion: nil)
    }
}