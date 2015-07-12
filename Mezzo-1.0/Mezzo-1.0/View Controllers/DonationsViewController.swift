//
//  DonationsViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/8/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

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
        
        // completionBlock for loading donations
        var completionBlock = { (result: [AnyObject]?, error: NSError?) -> Void in
            let loadedDonations = result as? [Donation] ?? []
            self.donations += loadedDonations
            self.donationSelectionStatuses = [Bool](count: (self.donations.count), repeatedValue: false)
            self.tableView.reloadData()
        }
        
        // determine whether user = org or donor, then load donations
        if let user = user as? Organization {
            addBarButton.enabled = false
            ParseHelper.getDonations(user, isUpcoming: true, completionBlock: completionBlock)
        } else if let user = user as? Donor {
            addBarButton.enabled = true
            ParseHelper.getDonations(user, isUpcoming: true, completionBlock: completionBlock)
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
            case "Send Donation Offer":
                var donationToOffer = Donation()
                donationToOffer.fromDonor = user as? Donor
                
                let source = sender.sourceViewController as! OrganizationChooserViewController
                
                let path = NSIndexPath(forRow: 1, inSection: source.selectedIndex!)
                let cell = source.tableView.cellForRowAtIndexPath(path) as! OrganizationBodyTableViewCell
                
                donationToOffer.toOrganization = cell.organization
                donationToOffer.pickupAt = cell.organization?.availableTimes[cell.timePickerView.selectedRowInComponent(0)]
                
                source.donation.offer()
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
        // search for the given donor
    }
    
}




















