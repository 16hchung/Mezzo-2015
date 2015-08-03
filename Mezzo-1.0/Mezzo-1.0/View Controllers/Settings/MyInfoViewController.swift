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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // add border to text view
        specialInstructions.layer.borderWidth = 1.0
        let grayColor = UIColor(white: 0.875, alpha: 1.000)
        specialInstructions.layer.borderColor = grayColor.CGColor
//        specialInstructions.layer.borderColor = UIColor.blackColor().CGColor
        specialInstructions.layer.cornerRadius = 5.0
        
        addDoneToKeyboard() // add done toolbar
        
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: keyboard handling
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notif: NSNotification) {
        if let info = notif.userInfo {
            let keyboardSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
            let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            // if currently editing special instructions text view, scroll up
            if specialInstructions.isFirstResponder() {
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
    
    func doneButtonAction() {
        self.view.endEditing(true)
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