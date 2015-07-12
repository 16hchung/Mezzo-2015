//
//  FoodTypeTableViewCell.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class FoodTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var foodLabel: UILabel!
//
//    var isSelected: Bool! = false {
//        didSet {
//            if let isSelected = isSelected {
//                check.hidden = !isSelected
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
