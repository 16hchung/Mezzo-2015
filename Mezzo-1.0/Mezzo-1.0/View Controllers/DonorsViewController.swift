//
//  DonorsViewController.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 7/8/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class DonorsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: enums
    
    // search bar modes
    private enum SearchBarState {
        case DefaultMode
        case SearchMode
    }
    
    private var state: SearchBarState = .DefaultMode
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: table view and search bar delegates

extension DonorsViewController: UITableViewDataSource {
    // MARK: sections
    
    // number of sections = 2 (donors that are scheduled and donors that aren't)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // sets section header titles
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Donation Scheduled"
        case 1:
            return "No Donations Scheduled"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch (section) {
//        case 0:
//            // TODO
//            // grab from Parse
//        case 1:
//            // grab from Parse
//        }
        return 1 // TODO: comment out once Parse queries are available
    }
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DonorCell") as! DonorTableViewCell
        
        // populate with data about the donor
        
        return cell
    }
}

extension DonorsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // segue to the respective donor's donation(s)
    }
}

extension DonorsViewController: UISearchBarDelegate {
    // user begins editing the search text
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    // user changed the search text, so filter through notes and update view
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // search for the given donor
    }

}