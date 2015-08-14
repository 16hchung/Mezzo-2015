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
        static let acceptedGreen = UIColor(red: 22.0/255.0, green: 160.0/255.0, blue: 133.0/255.0, alpha:1.000)
//        static let declinedBrightRed = UIColor(red:0.937, green:0.325, blue:0.314, alpha:1.000)
        static let completedGray = UIColor(white: 0.620, alpha: 1.000)
        static let declinedMutedRed = UIColor(red: 168.0/255.0, green: 47.0/255.0, blue: 32.451/255.0, alpha:1.000)
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
            button.layer.borderWidth = 1.0
            button.setTitleColor(color, forState: .Normal)
            if bold {
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(19.0)
                button.layer.borderWidth = 2.0
            }
        }
    }
    
    static func iconForStatus(status: String, fontSize: CGFloat, spacing: CGFloat, colored: Bool) -> NSMutableAttributedString {
        var iconAttributedStr: NSMutableAttributedString!
        var attributes: [NSObject : AnyObject] = [:]
        var iconStr: String = ""
        var textColor = UIColor.whiteColor()
        
        switch status {
        case Donation.DonationState.Accepted.rawValue, Donation.DonationState.Completed.rawValue:
            iconStr = NSString(UTF8String: "\u{e600}") as! String
            if colored { textColor = Colors.acceptedGreen }
        case Donation.DonationState.Declined.rawValue:
            iconStr = NSString(UTF8String: "\u{e601}") as! String
            if colored { textColor = Colors.declinedMutedRed }
        case Donation.DonationState.Offered.rawValue:
            iconStr = NSString(UTF8String: "\u{e602}") as! String
            if colored { textColor = Colors.pendingOrange }
        default:
            iconStr = ""
        }
        
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "icomoon", size: fontSize)
        
        let lineSpacing = NSMutableParagraphStyle()
        lineSpacing.lineSpacing = spacing
        attributes[NSParagraphStyleAttributeName] = lineSpacing
        
        iconAttributedStr = NSMutableAttributedString(string: iconStr, attributes: attributes)
        
        return iconAttributedStr
    }
    
    static func iconForFood(food: String, fontSize: CGFloat, color: UIColor) -> NSMutableAttributedString {
        var iconAttributedStr: NSMutableAttributedString!
        var attributes: [NSObject : AnyObject] = [:]
        var iconStr: String = ""
        
        switch food {
        case "Grains/Beans":
            iconStr = NSString(UTF8String: "\u{e604}") as! String + " "
        case "Fruits/Veggies":
            iconStr = NSString(UTF8String: "\u{e603}") as! String + " "
        case "Meats":
            iconStr = NSString(UTF8String: "\u{e605}") as! String + " "
        case "Dairy":
            iconStr = NSString(UTF8String: "\u{e602}") as! String + " "
        case "Oils/Condiments":
            iconStr = NSString(UTF8String: "\u{e601}") as! String + " "
        case "Baked Goods":
            iconStr = NSString(UTF8String: "\u{e600}") as! String + " "
        default:
            iconStr = NSString(UTF8String: "\u{e606}") as! String + " "
        }
        
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = UIFont(name: "FoodItems", size: fontSize)

        iconAttributedStr = NSMutableAttributedString(string: iconStr, attributes: attributes)
        
        return iconAttributedStr
    }
    
}