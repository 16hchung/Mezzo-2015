//
//  KeyboardHelper.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 8/4/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import ConvenienceKit

class KeyboardHelper {
    static func registerForKeyboardNotifications(viewController: UIViewController) {
        // register for keyboard show/hide notifications
        NSNotificationCenter.defaultCenter().addObserver(viewController, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(viewController, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    static func deregisterFromKeyboardNotifications(viewController: UIViewController) {
        NSNotificationCenter.defaultCenter().removeObserver(viewController)
    }
    
    /// Default behavior for keyboardWillBeHidden function. Undoes any scroll insets (squashing the scroll view) and content offsets (moving the scroll view content up or down).
    static func resetScrollInsetsToNormal(viewController: UIViewController, scrollView: UIScrollView) {
        let contentInset = UIEdgeInsetsZero
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        scrollView.setContentOffset(CGPointMake(0.0, -viewController.view.frame.origin.y / 2), animated: true)
    }
    
    static func addScrollInsets(viewController: UIViewController, notifInfo: [NSObject:AnyObject], scrollView: UIScrollView, textViewsToCheck: [TextView]) {
        let keyboardSize = notifInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        // check text inputs that may be hidden
        for textView in textViewsToCheck {
            if textView.isFirstResponder() { // if the text input is currently being edited
                var rect = viewController.view.frame
                rect.size.height -= keyboardSize!.height + 50
                if !CGRectContainsPoint(rect, CGPointMake(textView.frame.origin.x, textView.frame.origin.y + 70)) {
//                    let scrollPoint = CGPointMake(0.0, -textView.frame.origin.y + keyboardSize!.height)
                    let scrollPoint = CGPointMake(0.0, textView.frame.origin.y - 20)
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
    }
    
    static func addScrollInsets(viewController: UIViewController, notifInfo: [NSObject:AnyObject], scrollView: UIScrollView, textFieldsToCheck: [UITextField]) {
        let keyboardSize = notifInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        // check text inputs that may be hidden
        for textField in textFieldsToCheck {
            if textField.isFirstResponder() { // if the text input is currently being edited
                var rect = viewController.view.frame
                rect.size.height -= keyboardSize!.height + 50
                if !CGRectContainsPoint(rect, CGPointMake(textField.frame.origin.x, textField.frame.origin.y + 70)) {
                    //                    let scrollPoint = CGPointMake(0.0, -textView.frame.origin.y + keyboardSize!.height)
                    let scrollPoint = CGPointMake(0.0, textField.frame.origin.y - 20)
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
    }
    
    static func addDoneToKeyboard(viewController: UIViewController, textFields: [UITextField], textViews: [TextView]) {
        // create "Done" toolbar
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: viewController, action: Selector("doneButtonAction"))
        
        var items = NSMutableArray()
        items.addObject(flexSpace)
        items.addObject(done)
        
        doneToolbar.items = items as [AnyObject]
        doneToolbar.sizeToFit()
        
        // add to appropriate text fields and text views
        for field in textFields { field.inputAccessoryView = doneToolbar }
        for view in textViews { view.inputAccessoryView = doneToolbar }
    }
    
    static func dismissKeyboard(viewController: UIViewController) {
        viewController.view.endEditing(true)
    }
}

protocol KeyboardProtocol {
    func keyboardWasShown(notif: NSNotification)
    func keyboardWillBeHidden(notif: NSNotification)
}

protocol DoneButtonProtocol {
    func doneButtonAction()
}