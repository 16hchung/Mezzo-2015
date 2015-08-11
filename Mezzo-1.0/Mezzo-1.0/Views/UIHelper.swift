//
//  UIHelper.swift
//  Mezzo-1.0
//
//  Created by Claire Huang on 8/11/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit

class UIHelper {
    // MARK: colors
    struct Colors {
        static let buttonBlue = UIColor(red:0.392, green:0.710, blue:0.965, alpha:1.000)
        static let pendingOrange = UIColor(red:1.000, green:0.655, blue:0.149, alpha:1.000)
        static let acceptedGreen = UIColor(red: 0.332, green:0.824, blue:0.463, alpha:1.000)
        static let declinedBrightRed = UIColor(red:0.937, green:0.325, blue:0.314, alpha:1.000)
        static let completedGray = UIColor(white: 0.620, alpha: 1.000)
        static let declinedMutedRed = UIColor(red:0.898, green:0.451, blue:0.451, alpha:1.000)
    }
    
    /// Resizes the height of a text view based on its contents.
    static func resizeTextView(textView: UITextView, heightConstraint: NSLayoutConstraint) {
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.max)).height
        heightConstraint.constant = height
    }
    
    /// Removes a UI object and its constraints from the superview. (CAUTION: do not use in reusable table view cells)
    static func hideObjects(objects: [AnyObject]) {
        for object in objects {
            object.removeFromSuperview()
            object.removeConstraints(object.constraints())
        }
    }
    
    /// Colors a UIButton's outline and text, and optionally bolds the text inside for emphasis.
    static func colorButtons(buttons: [UIButton], color: UIColor, bold: Bool) {
        for button in buttons {
            button.layer.borderColor = color.CGColor
            button.layer.borderWidth = 2.0
            button.setTitleColor(color, forState: .Normal)
            if bold { button.titleLabel?.font = UIFont.boldSystemFontOfSize(19.0) }
        }
    }
    
}