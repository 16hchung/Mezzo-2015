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
    
    // MARK: Properties
    
    var donations = [Donation]()
    /// shows selection status for every section in table view
    private var donationSelectionStatuses: [Bool] = []
    
    // search bar modes
    private enum SearchBarState {
        case DefaultMode
        case SearchMode
    }
    private var state: SearchBarState = .DefaultMode
    
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting delegate + datasource
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        reloadData()
        
    }
    
    func reloadData() {
        // load donations (getDonations already deals with type of user)
        ParseHelper.getDonations(isUpcoming: true) { (result: [AnyObject]?, error: NSError?) -> Void in
            // do the add button thing
            if let user = PFUser.currentUser()! as? User where user.donor != nil {
                self.navigationItem.rightBarButtonItem = self.addBarButton
            } else if let user = PFUser.currentUser()! as? User where user.organization != nil {
                self.navigationItem.rightBarButtonItem = nil
            }
            
            // result should be an array of offers => convert to array associated donations
            let loadedDonations = result?.map { $0[ParseHelper.OfferConstants.donationProperty] } as? [Donation] ?? []
            // cast then recast from Set (no duplicates) back to Array
            let noDuplicateDonations = Array(Set(loadedDonations))
            
            self.donations += noDuplicateDonations
            self.donationSelectionStatuses = [Bool](count: (self.donations.count), repeatedValue: false)
            self.tableView.reloadData()
            
            // donors can't add two donations at once
            if loadedDonations.count > 0 { self.addBarButton.enabled == false }
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
                
                var selectedOrgCellArray = [Organization]()
                
                for cellSection in 0..<tableView.numberOfSections() {
                    let path = NSIndexPath(forRow: 0, inSection: cellSection)
                    
                    if let cell = tableView.cellForRowAtIndexPath(path) as? OrganizationHeaderTableViewCell where cell.checkBoxButton.selected {
                        
                        selectedOrgCellArray.append(cell.organization!)
                    }
                }
                
//                var someDonor = PFUser.currentUser()! as? User
                
                source.donation.fromDonor = (PFUser.currentUser()! as? User)?.donor
                
                source.donation.offer { (success: Bool, error: NSError?) -> Void in
                    for org in selectedOrgCellArray {
                        ParseHelper.addOfferToDonation(source.donation, toOrganization: org)
                    }
                    
                    self.reloadData()
                }
            default:
                break
            }
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            
            if let orgUser = (PFUser.currentUser() as? User)?.organization where headerCell.donation.donationState == Donation.DonationState.Offered {
                headerCell.declineButton.hidden == false
                headerCell.acceptButton.hidden == false
            } else {
                headerCell.declineButton.hidden == true
                headerCell.acceptButton.hidden == true
            }
            
            return headerCell
            
        } else {
            
            let bodyCell = tableView.dequeueReusableCellWithIdentifier("Donation Body") as! DonationTableViewCell
            bodyCell.donation = self.donations[indexPath.section]
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else {
            return 120
        }
    }
}

// MARK: - Search Bar Delegate

extension DonationsViewController: UISearchBarDelegate {
    // user begins editing the search text
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    // user changed the search text, so filter through notes and update view
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: search for the given donor
    }
    
}




















