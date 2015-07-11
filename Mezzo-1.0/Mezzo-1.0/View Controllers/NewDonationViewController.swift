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
    var donation: Donation? {
        get {
            donation = Donation()
            // set properties
            return donation
        }
    }
    
    // MARK: Methods
    
    func saveDonation() {
        // TODO
    }
    
    // MARK: VC Lifecycle

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
