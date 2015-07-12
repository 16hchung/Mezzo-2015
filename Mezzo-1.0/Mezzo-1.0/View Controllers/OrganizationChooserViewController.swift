//
//  OrganizationChooserViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class OrganizationChooserViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var donation: Donation!
    
    var organizations: [Organization]!
    var orgSelectionStatuses: [Bool] = []
    
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

// MARK: - Table View Data Source Protocol

extension OrganizationChooserViewController: UITableViewDataSource {
    // MARK: Sections
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return organizations.count
    }
    
    // MARK: Cells
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orgSelectionStatuses[section] {
            return 2
        } else {
            return 1
        }
    }
    
    // load a new table view cell with donor's name and time of next donation (if applicable)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("Donation Header") as! OrganizationHeaderTableViewCell
            headerCell.organization = self.organizations[indexPath.section]
            return headerCell
        } else {
            let bodyCell = tableView.dequeueReusableCellWithIdentifier("Donation Body") as! OrganizationBodyTableViewCell
            bodyCell.organization = self.organizations[indexPath.section]
            return bodyCell
        }
    }
}
//
//// MARK: - Table View Delegate Protocol
//
//extension DonationsViewController: UITableViewDelegate {
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        // toggle selection status
//        donationSelectionStatuses[indexPath.section] = !donationSelectionStatuses[indexPath.section]
//        
//        // create index paths being inserted/deleted
//        var paths = [NSIndexPath]()
//        paths.append(NSIndexPath(forRow: 1, inSection: indexPath.section))
//        
//        // animate row insertion/deletion
//        tableView.beginUpdates()
//        if donationSelectionStatuses[indexPath.section] {
//            tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
//        } else {
//            tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
//        }
//        tableView.endUpdates()
//        
//    }
//}
