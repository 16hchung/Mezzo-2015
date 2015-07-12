//
//  NewDonationViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class NewDonationViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var foodTypesTableView: UITableView!
    @IBOutlet weak var weightPickerView: UIPickerView!
    
    // MARK: Properties
    
    // TODO: research how to enforce lack of setting capabilities
    /// donation being created (no setting)
    var donation = Donation()
    
    // MARK: Methods

    func saveDonation() {
        donation.weightRange = Donation.incrementedAmountRanges[weightPickerView.selectedRowInComponent(0)]
    }
    
    // MARK: VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodTypesTableView.delegate = self
        foodTypesTableView.dataSource = self
        
        weightPickerView.delegate = self
        weightPickerView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Choose Organization":
                saveDonation()
                let orgChooserVC = segue.destinationViewController as! OrganizationChooserViewController
                orgChooserVC.donation = self.donation
            default:
                break
            }

        }
    }
    

}

// MARK: Table View Data Source Protocol

extension NewDonationViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Donation.foodTypes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Food Type Cell") as! FoodTypeTableViewCell
        cell.foodLabel.text = Donation.foodTypes[indexPath.row]
        return cell
    }
}

// MARK: Table View Delegate Protocol

extension NewDonationViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodTypeTableViewCell
        
        // update checkmark
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            donation.foodDescription.append(cell.foodLabel.text!)
            println(donation.foodDescription)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            var index = find(donation.foodDescription, cell.foodLabel.text!)
            donation.foodDescription.removeAtIndex(index!)
            println(donation.foodDescription)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: Picker View Delegates

extension NewDonationViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return Donation.incrementedAmountRanges[row]
    }
}

extension NewDonationViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Donation.incrementedAmountRanges.count
    }
}

























