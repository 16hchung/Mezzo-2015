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
            allSortedKeys.sort { return $0.updatedAt < $1.updatedAt }
            
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
        
        // pull to refresh setup
        self.tableView.addSubview(refreshControl)
        
//        searchBarState = .DefaultMode
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
                    loadedDonations = loadedDonations.filter { $0.checkIfExpiredOrCompleted() } // update any already completed donations
                    
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
                        if donation.checkIfExpiredOrCompleted() { pendingDonations.append(donation) }
                    }
                    
                    // then load any accepted donations
                    ParseHelper.getUpcomingDonationsForRecipient(orgUser: orgUser, isPending: false) { (result: [AnyObject]?, error: NSError?) -> Void in
                        if let error = error {
                            ErrorHandling.defaultErrorHandler(error)
                            
                        } else if var acceptedDonations = result as? [Donation] {
                            acceptedDonations = acceptedDonations.filter { $0.checkIfExpiredOrCompleted() } // update any already completed donations
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
        switch segmentedControl.selectedSegmentIndex {
        case UPCOMING:
            reloadUpcomingDonationsData()
        case COMPLETED:
            reloadCompletedDonationsData()
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
            // donors can't add two donations at once
            if !noUpcomingDonations { navigationItem.rightBarButtonItem?.enabled = false }
            else { navigationItem.rightBarButtonItem?.enabled = true }
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
                let source = sender.sourceViewController as! OrganizationChooserViewController
                
                source.donation.offer ((PFUser.currentUser()! as! User).donor!, toOrgs: source.selectedRecipientOrganizations)   { (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                        
                    } else {
                        for org in source.selectedRecipientOrganizations {
                            ParseHelper.addOfferToDonation(source.donation, toOrganization: org)
                        }
                    }
                    
                }
            default:
                break
            }
        }
    }
}

// MARK: - Table View Data Source Protocol

extension DonationsViewController: UITableViewDataSource {
    
    // MARK: Cells
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }
    
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("Donation Header", forIndexPath: indexPath) as! DonationHeaderTableViewCell
        headerCell.delegate = self
        
        let donation = orderedDonationKeys[indexPath.row]
        headerCell.pendingOffers = donations[donation]
        headerCell.donation = donation
        
//        headerCell.updateConstraintsIfNeeded()
        for label in headerCell.multiLineLabels! {
            label.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds)
        }
        headerCell.setNeedsLayout()
        headerCell.layoutIfNeeded()
        
        return headerCell
        
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

extension DonationsViewController: DonationHeaderCellDelegate {
    
    func showTimePickingDialogue(cell: DonationHeaderTableViewCell) {
        
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
    
    func showDeclineDialogue(cell: DonationHeaderTableViewCell) {
        
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
    
    func cancelDonation(cell: DonationHeaderTableViewCell) {
        cell.donation.cancel { (success, error) -> Void in
            self.segmentedControlChanged(nil)
        }
    }
}































