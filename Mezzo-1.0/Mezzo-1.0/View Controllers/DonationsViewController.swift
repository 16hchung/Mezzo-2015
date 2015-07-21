//
//  DonationsViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/8/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Parse

class DonationsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var emptyStateButton: UIButton!
    
    // MARK: Properties
    
    var donations = [Donation]()
    /// shows selection status for every section in table view
    private var donationSelectionStatuses: [Bool] = []
    
    // search bar modes
    private enum SearchBarState {
        case DefaultMode
        case SearchMode
    }

    private var searchBarState: SearchBarState = .DefaultMode {
        didSet {
            switch(searchBarState) {
            case .DefaultMode:
                searchBar.resignFirstResponder()
                searchBar.text = ""
                searchBar.showsCancelButton = false
            case .SearchMode:
                let searchText = searchBar.text ?? ""
                searchBar.showsCancelButton = true
                // donations = searchDonations(searchText)
            }
        }
    }
    
    // segmented control modes
    private let UPCOMING: Int  = 0
    private let COMPLETED: Int = 1
    
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting delegate + datasource
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        segmentedControl.selectedSegmentIndex = UPCOMING
        if(segmentedControl.selectedSegmentIndex == UPCOMING) { reloadUpcomingDonationsData() }
        
        searchBarState = .DefaultMode
    }
    
    // MARK: reload donations data
    
    private func reloadUpcomingDonationsData() {
        // load donations (getDonations already deals with type of user)
        if let donorUser = (PFUser.currentUser() as! User).donor {
            ParseHelper.getUpcomingDonationsForDonor(donorUser: donorUser) { (result: [AnyObject]?, error: NSError?) -> Void in
                let loadedDonations =  result as? [Donation] ?? []
                self.donations = loadedDonations
                self.reloadUI()
            }
        } else if let orgUser = (PFUser.currentUser() as! User).organization {
            // load pending donation offers first
            ParseHelper.getUpcomingDonationsForRecipient(orgUser: orgUser, isPending: true) { (result: [AnyObject]?, error: NSError?) -> Void in
                let pendingOffers = result as? [PFObject] ?? []
                var pendingDonations:[Donation] = [Donation]()
                
                for offer in pendingOffers {
                    let donation = offer.objectForKey(ParseHelper.OfferConstants.donationProperty) as! Donation
                    pendingDonations.append(donation)
                }
                
                // then load any accepted donations
                ParseHelper.getUpcomingDonationsForRecipient(orgUser: orgUser, isPending: false) { (result: [AnyObject]?, error: NSError?) -> Void in
                    let acceptedDonations = result as? [Donation] ?? []
                    self.donations = pendingDonations + acceptedDonations
                    self.reloadUI()
                }
            }
        }
    }
    
    private func reloadCompletedDonationsData() {
        ParseHelper.getCompletedDonations() { (result: [AnyObject]?, error: NSError?) -> Void in
            let loadedDonations = result as? [Donation] ?? []
            self.donations = loadedDonations
            self.reloadUI()
        }
    }
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case UPCOMING:
            reloadUpcomingDonationsData()
        case COMPLETED:
            reloadCompletedDonationsData()
        default:
            reloadUpcomingDonationsData()
        }
    }
    
    // MARK: update UI after data has been loaded
    
    private func reloadUI() {
        self.donationSelectionStatuses = [Bool](count: (self.donations.count), repeatedValue: false)
        self.tableView.reloadData()
        
        // load the appropriate empty state button if necessary
        self.updateNoDonationsButton()
        
        // do the add button thing
        if let user = PFUser.currentUser()! as? User where user.donor != nil {
            self.navigationItem.rightBarButtonItem = self.addBarButton
            // donors can't add two donations at once
            if self.donations.count > 0 { self.addBarButton.enabled == false }
        } else if let user = PFUser.currentUser()! as? User where user.organization != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
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
//                var donationToOffer = Donation()
                
//
//                let path = NSIndexPath(forRow: 1, inSection: source.selectedIndex!)
//                let cell = source.tableView.cellForRowAtIndexPath(path) as! OrganizationBodyTableViewCell
//                
//                source.donation.fromDonor = (PFUser.currentUser()! as? User)?.donor
//                source.donation.toOrganization = cell.organization
//                
//                // TODO: fix pickup time
//                //source.donation.pickupAt = cell.organization?.availableTimes[cell.timePickerView.selectedRowInComponent(0)]
//                
//                source.donation.offer()
                
                let source = sender.sourceViewController as! OrganizationChooserViewController
                
                source.donation.fromDonor = (PFUser.currentUser()! as? User)?.donor
                
                source.donation.offer { (success: Bool, error: NSError?) -> Void in
                    for org in source.selectedRecipientOrganizations {
                        ParseHelper.addOfferToDonation(source.donation, toOrganization: org)
                    }
                    
                    self.reloadUpcomingDonationsData()
                }
            default:
                break
            }
        }
    }
}

// MARK: - Table View Data Source Protocol

extension DonationsViewController: UITableViewDataSource {
    // MARK: Sections
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return donations.count
    }
    
    // MARK: Cells
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if donationSelectionStatuses[section] {
            return 2
        } else {
            return 1
        }
    }
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("Donation Header") as! DonationHeaderTableViewCell
            headerCell.donation = self.donations[indexPath.section]
            
            return headerCell
            
        } else {
            
            let bodyCell = tableView.dequeueReusableCellWithIdentifier("Donation Body") as! DonationTableViewCell
            ParseHelper.getOffersForDonation(donations[indexPath.section]) { (result: [AnyObject]?, error: NSError?) -> Void in
                bodyCell.pendingOffers = result as? [PFObject]
                bodyCell.donation = self.donations[indexPath.section]
            }
            return bodyCell
        }
    }
}

// MARK: - Table View Delegate Protocol

extension DonationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // toggle selection status
        donationSelectionStatuses[indexPath.section] = !donationSelectionStatuses[indexPath.section]
        
        // create index paths being inserted/deleted
        var paths = [NSIndexPath]()
        paths.append(NSIndexPath(forRow: 1, inSection: indexPath.section))
        
        // animate row insertion/deletion
        tableView.beginUpdates()
        if donationSelectionStatuses[indexPath.section] {
            tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
        } else {
            tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
        }
        tableView.endUpdates()
        
    }
}

// MARK: - Search Bar Delegate

extension DonationsViewController: UISearchBarDelegate {
    // user begins editing the search text
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBarState = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBarState = .DefaultMode
    }
    
    // user changed the search text, so filter through notes and update view
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: search for the given donor
        // donations = searchDonations(searchText)
    }
}