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
    
    @IBOutlet var foodTypeButtons: [UIButton]!
    @IBOutlet weak var weightPickerView: UIPickerView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
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
        
        // set text wrap for food type button labels
        for button in foodTypeButtons {
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        
        weightPickerView.delegate = self
        weightPickerView.dataSource = self
        
        nextButton.enabled = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: food type buttons
    @IBAction func foodTypeButtonSelected(sender: AnyObject) {
        let button = sender as! UIButton
        
        if (!button.selected) { // if image is empty checkbox, select
            button.selected = true
            donation.foodDescription.append(button.titleLabel!.text!)
            println(donation.foodDescription)
        } else { // if image is filled checkbox, deselect
            button.selected = false
            let index = find(donation.foodDescription, button.titleLabel!.text!)
            donation.foodDescription.removeAtIndex(index!)
            println(donation.foodDescription)
        }
        
        // next button shouldn't be enabled unless foodDescription is populated
        nextButton.enabled = !donation.foodDescription.isEmpty
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Choose Time":
                saveDonation()
                let orgChooserVC = segue.destinationViewController as! PickupTimeViewController
                orgChooserVC.donation = self.donation
            default:
                break
            }

        }
    }
    

}

// MARK: Table View Delegate Protocol
//
//extension NewDonationViewController: UITableViewDelegate {
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodTypeTableViewCell
//        
//        // update checkmark
//        if cell.accessoryType == UITableViewCellAccessoryType.None {
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            donation.foodDescription.append(cell.foodLabel.text!)
//            println(donation.foodDescription)
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryType.None
//            var index = find(donation.foodDescription, cell.foodLabel.text!)
//            donation.foodDescription.removeAtIndex(index!)
//            println(donation.foodDescription)
//        }
//
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
//}

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