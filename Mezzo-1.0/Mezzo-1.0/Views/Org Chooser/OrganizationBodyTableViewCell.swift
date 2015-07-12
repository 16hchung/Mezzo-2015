//
//  OrganizationBodyTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/12/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class OrganizationBodyTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var missionStatementLabel: UILabel!
    @IBOutlet weak var timePickerView: UIPickerView!
    
    // MARK: Properties
    
    var organization: Organization? {
        didSet {
            if let organization = organization {
                missionStatementLabel.text = organization.missionStatement
                
                timePickerView.delegate = self
                timePickerView.dataSource = self
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


// MARK: - UIPickerView Data Source
// http://makeapppie.com/tag/uipickerview-in-swift/
extension OrganizationBodyTableViewCell: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return organization!.availableTimes.count
    }
}

// MARK: - UIPickerView Delegate

extension OrganizationBodyTableViewCell: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return organization!.availableTimes[row]
    }
    
}