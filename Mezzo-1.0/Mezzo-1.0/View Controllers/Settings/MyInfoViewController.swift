//
//  MyInfoViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/30/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import ConvenienceKit

class MyInfoViewController: UIViewController {
    
    @IBOutlet weak var managerName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var specialInstructions: TextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var specialInstructionsActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // add border to text view
        specialInstructions.layer.borderWidth = 1.0
        let grayColor = UIColor(white: 0.875, alpha: 1.000)
        specialInstructions.layer.borderColor = grayColor.CGColor
        specialInstructions.layer.cornerRadius = 5.0
        
        addDoneToKeyboard() // add done toolbar
        
        // register for keyboard show/hide notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        phoneNumber.delegate = self // set text field delegate
        specialInstructions.delegate = self // set text view delegate
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: keyboard handling
    
    func keyboardWasShown(notif: NSNotification) {
        if let info = notif.userInfo {
            let keyboardSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
            let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            // if currently editing special instructions text view, scroll up
            if specialInstructionsActive {
                var rect = self.view.frame
                rect.size.height -= keyboardSize!.height
                if !CGRectContainsPoint(rect, CGPointMake(specialInstructions.frame.origin.x, specialInstructions.frame.origin.y + 100)) {
                    let scrollPoint = CGPointMake(0.0, -(specialInstructions.frame.origin.y - keyboardSize!.height))
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
    }
    
    func keyboardWillBeHidden(notif: NSNotification) {
        let contentInset = UIEdgeInsetsZero
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        scrollView.setContentOffset(CGPointMake(0.0, -self.view.frame.origin.y / 2), animated: true)
    }
    
    /// Adds done toolbar to the keyboards of all three text inputs.
    private func addDoneToKeyboard() {
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items = NSMutableArray()
        items.addObject(flexSpace)
        items.addObject(done)
        
        doneToolbar.items = items as [AnyObject]
        doneToolbar.sizeToFit()
        
        specialInstructions.inputAccessoryView = doneToolbar
        phoneNumber.inputAccessoryView = doneToolbar
        managerName.inputAccessoryView = doneToolbar
    }
    
    /// Dismisses keyboard when done toolbar button is tapped.
    func doneButtonAction() {
        self.view.endEditing(true)
    }

}

extension MyInfoViewController: UITextFieldDelegate {
    
    /// Formats phone number string while user is typing
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            // take out any non-number text
            var components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            var decimalString = "".join(components) as NSString
            
            var length = decimalString.length
            var hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                var newLength = (textField.text as NSString).length + (string as NSString).length - range.length as Int
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            var formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.appendString("1 ")
                index += 1
            }
            
            if (length - index) > 3 {
                var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            
            if length - index > 3 {
                var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            var remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        } else {
            return true
        }
    }
}

extension MyInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        self.specialInstructionsActive = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.specialInstructionsActive = false
    }
}