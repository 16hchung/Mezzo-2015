//
//  AvailabilityViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/31/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse
import Mixpanel

class FoodPreferencesViewController: UIViewController {

    @IBOutlet weak var foodTextView: TextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var saveButtonActive: Bool! {
        didSet {
            saveButton.enabled = saveButtonActive
            if !saveButtonActive {
                saveButton.title = "Saved"
                saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16.0)], forState: .Normal)
            } else {
                saveButton.title = "Save"
                saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(17.0)], forState: .Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add border and color to text view
        foodTextView.layer.borderWidth = 1.0
        let grayColor = UIColor(white: 0.875, alpha: 1.000)
        foodTextView.layer.borderColor = grayColor.CGColor
        foodTextView.layer.cornerRadius = 5.0
        
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("show setting", properties: ["setting type" : "food preferences"])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let org = (PFUser.currentUser() as! User).organization {
            org.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.foodTextView.text = org["unacceptableFoods"] as? String ?? ""
                }
            })
        }
        
        saveButtonActive = false
        
        KeyboardHelper.registerForKeyboardNotifications(self)
        KeyboardHelper.addDoneToKeyboard(self, textFields: [], textViews: [foodTextView])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.deregisterFromKeyboardNotifications(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Save Food Policies" {
            let org = (PFUser.currentUser() as! User).organization!
            org["unacceptableFoods"] = foodTextView.text
            org.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.performSegueWithIdentifier("Save Food Policies", sender: self)
                }
            })
            
            let mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("next", properties: ["screen" : "food policies", "action" : "save"])
        }
    }
}

extension FoodPreferencesViewController: KeyboardProtocol {
    func keyboardWasShown(notif: NSNotification) {
        saveButtonActive = true
        KeyboardHelper.addScrollInsets(self, notifInfo: notif.userInfo ?? [:], scrollView: self.scrollView, textViewsToCheck: [foodTextView])
    }
    
    func keyboardWillBeHidden(notif: NSNotification) {
        KeyboardHelper.resetScrollInsetsToNormal(self, scrollView: self.scrollView)
    }
}

extension FoodPreferencesViewController: DoneButtonProtocol {
    func doneButtonAction() {
        KeyboardHelper.dismissKeyboard(self)
    }
}