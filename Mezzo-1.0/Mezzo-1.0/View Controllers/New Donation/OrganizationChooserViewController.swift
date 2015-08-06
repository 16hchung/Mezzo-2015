//
//  OrganizationChooserViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import Mixpanel

class OrganizationChooserViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offerBarButton: UIBarButtonItem!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    // mixpanel setup
    let MIXPANEL_NEW_DONATION_EVENT = "new donation changed"
    let MIXPANEL_ACTION = "action"
    let MIXPANEL_VALUE = "value"
    let mixpanel = Mixpanel.sharedInstance()
    
    // MARK: Properties
    
    var donation: Donation!
    var organizations: [Organization]!
    
    var selectedIndex: Int? = nil {
        didSet {
            if selectedIndex == nil {
                mixpanel.track(MIXPANEL_NEW_DONATION_EVENT,
                    properties: [MIXPANEL_ACTION: "org expanded", MIXPANEL_VALUE: "closed"])
            } else {
                mixpanel.track(MIXPANEL_NEW_DONATION_EVENT,
                    properties: [MIXPANEL_ACTION: "org expanded", MIXPANEL_VALUE: "expanded"])
            }
        }
    }
    
    var selectedRecipientOrganizations = [Organization]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        offerBarButton.enabled = false
        
        loadingView.hidden = false
        // run Parse query
        ParseHelper.getAllOrgs { (result: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
                
            } else if let loadedOrgs = result as? [Organization] {
                self.organizations = loadedOrgs
                self.tableView.reloadData()
                self.loadingView.hidden = true
            }
        }
    }
}

// MARK: - Table View Data Source Protocol

extension OrganizationChooserViewController: UITableViewDataSource {
    // MARK: Sections
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return organizations?.count ?? 0
    }
    
    // MARK: Cells
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == nil || section != selectedIndex {
            return 1
        } else {
            return 2
        }
    }
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("Org Name Header", forIndexPath: indexPath) as! OrganizationHeaderTableViewCell
            
            headerCell.delegate = self
            
            headerCell.organization = self.organizations[indexPath.section]
            return headerCell
        } else {
            let bodyCell = tableView.dequeueReusableCellWithIdentifier("Org Body Cell") as! OrganizationBodyTableViewCell
            bodyCell.donorSpecifiedTimeRange = (donation.donorTimeRangeStart!, donation.donorTimeRangeEnd!)
            bodyCell.organization = self.organizations[indexPath.section]
            return bodyCell
        }
    }
}

extension OrganizationChooserViewController: OrgHeaderCellDelegate {
    
    func boxCheckedForOrgCell(orgCell: OrganizationHeaderTableViewCell) {
        
        if orgCell.checkBoxButton.selected {
            selectedRecipientOrganizations.append(orgCell.organization!)
        } else {
            selectedRecipientOrganizations = selectedRecipientOrganizations.filter { $0 != orgCell.organization! }
        }
        
        offerBarButton.enabled = selectedRecipientOrganizations.count != 0
        
        mixpanel.track(MIXPANEL_NEW_DONATION_EVENT,
            properties: [MIXPANEL_ACTION: "org chosen", MIXPANEL_VALUE: "N/A"])
    }
    
}

// MARK: - Table View Delegate Protocol

extension OrganizationChooserViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // create index paths being inserted/deleted
        var insertPaths = [NSIndexPath]()
        var deletePaths = [NSIndexPath]()
        
        // toggle selection status
        tableView.beginUpdates()
        if (selectedIndex == nil) { // first time selecting something
            insertPaths.append(NSIndexPath(forRow: 1, inSection: indexPath.section))
            tableView.insertRowsAtIndexPaths(insertPaths, withRowAnimation: UITableViewRowAnimation.Top)
            selectedIndex = indexPath.section // set selected index
        } else if (indexPath.section == selectedIndex) { // close
            deletePaths.append(NSIndexPath(forRow: 1, inSection: selectedIndex!)) // add path
            tableView.deleteRowsAtIndexPaths(deletePaths, withRowAnimation: UITableViewRowAnimation.Top) // remove current row
            selectedIndex = nil // reset selected index to be none
        } else { // open new and close the previously selected
            deletePaths.append(NSIndexPath(forRow: 1, inSection: selectedIndex!))
            insertPaths.append(NSIndexPath(forRow: 1, inSection: indexPath.section))
            
            tableView.deleteRowsAtIndexPaths(deletePaths, withRowAnimation: UITableViewRowAnimation.Top)
            tableView.insertRowsAtIndexPaths(insertPaths, withRowAnimation: UITableViewRowAnimation.Top)
            
            selectedIndex = indexPath.section // update selected index
        }
        tableView.endUpdates()
    }
}
