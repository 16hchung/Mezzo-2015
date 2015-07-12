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
    
    // MARK: Properties
    
    var donations = [Donation]()
    
    // search bar modes
    private enum SearchBarState {
        case DefaultMode
        case SearchMode
    }
    private var state: SearchBarState = .DefaultMode
    
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: load donations
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Navigation
    
    @IBAction func unwindToDonationsVC(sender: UIStoryboardSegue) {
        
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("Donation Header") as! DonationHeaderTableViewCell
        headerCell.donation = self.donations[section]
        return headerCell
    }
    
    // MARK: Cells
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let bodyCell = tableView.dequeueReusableCellWithIdentifier("Donation Body") as! DonationTableViewCell
        bodyCell.donation = self.donations[indexPath.section]
        return bodyCell
    }
}

// MARK: - Table View Delegate Protocol

extension DonationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // segue to the respective donor's donation(s)
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




















