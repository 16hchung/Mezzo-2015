//
//  MyInfoViewController.swift
//  Mezzo-1.0
//
//  Created by Heejung Chung on 7/30/15.
//  Copyright (c) 2015 MezzoAwesomeness. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse
import Mixpanel

class MyInfoViewController: UIViewController {
    
    @IBOutlet weak var managerName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var specialInstructionsLabel: UILabel!
    @IBOutlet weak var specialInstructions: TextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutMezzoButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var saveButtonActive: Bool! {
        didSet {
            saveButton.enabled = saveButtonActive
            if !saveButtonActive {
                saveButton.title = "Saved"
                saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16.0)], forState: .Normal)
            } else {
                saveButton.title = "Save"
                saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], forState: .Normal)
            }
        }
    }
    
    let DONOR = true
    let ORG = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("show setting", properties: ["setting type" : "my info"])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // user-specific setup
        if let donor = (PFUser.currentUser() as! User).donor {
            // add border to text view
            specialInstructions.layer.borderWidth = 1.0
            let grayColor = UIColor(white: 0.875, alpha: 1.000)
            specialInstructions.layer.borderColor = grayColor.CGColor
            specialInstructions.layer.cornerRadius = 5.0
                        
            donor.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.loadMyInfo(donor, isDonor: self.DONOR)
                }
            })
            
        } else if let org = (PFUser.currentUser() as! User).organization {
            self.hideOrgSettings()
            
            org.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.loadMyInfo(org, isDonor: self.ORG)
                }
            })
        }
        
        saveButtonActive = false
        
        KeyboardHelper.addDoneToKeyboard(self, textFields: [managerName, phoneNumber], textViews: [specialInstructions])
        KeyboardHelper.registerForKeyboardNotifications(self)
        
        phoneNumber.delegate = self // set text field delegate
    }
    
    override func viewWillDisappear(animated: Bool) {
        KeyboardHelper.deregisterFromKeyboardNotifications(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func aboutMezzoPressed(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("show setting", properties: ["setting type" : "about mezzo"])
    }
    
    @IBAction func textFieldChanged(sender: UITextField) {
        let mixpanel = Mixpanel.sharedInstance()
        
        switch sender {
        case managerName:
            mixpanel.track("edit setting", properties: ["field" : "manager name", "value" : "N/A"])
        case phoneNumber:
            mixpanel.track("edit setting", properties: ["field" : "phone number", "value" : "N/A"])
        default:
            break
        }
    }
    
    private func hideOrgSettings() {
        specialInstructions.hidden = true
        specialInstructionsLabel.hidden = true
        aboutMezzoButton.hidden = true
    }
    
    // MARK: load and save settings info
    
    private func loadMyInfo(user: PFObject, isDonor: Bool) {
        managerName.text = user["managerName"] as? String ?? ""
        phoneNumber.text = user["phoneNumber"] as? String ?? ""
        
        if isDonor == DONOR {
            specialInstructions.text = user["specialInstructions"] as? String ?? ""
        }
    }
    
    private func saveMyInfo(user: PFObject, isDonor: Bool, callback: PFBooleanResultBlock) {
        user["managerName"] = managerName.text
        user["phoneNumber"] = phoneNumber.text
        
        if isDonor == DONOR {
            user["specialInstructions"] = specialInstructions.text
        }
        
        user.saveInBackgroundWithBlock(callback)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Save my info" {
            let mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("next", properties: ["screen" : "my info", "action" : "save"])
            
            var user: PFObject?
            var isDonor: Bool?
            
            if let donor = (PFUser.currentUser() as! User).donor {
                user = donor
                isDonor = DONOR
            } else if let org = (PFUser.currentUser() as! User).organization {
                user = org
                isDonor = ORG
            }
            
            saveMyInfo(user!, isDonor: isDonor!, callback: { (success, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                } else {
                    self.performSegueWithIdentifier("Save my info", sender: self)
                }
            })
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            println("back button tapped")
            let mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("back", properties: ["from screen": "settings my info"])
        }
    }
}
 
// MARK: keyboard handling

extension MyInfoViewController: KeyboardProtocol {
    func keyboardWasShown(notif: NSNotification) {
        saveButtonActive = true

        KeyboardHelper.addScrollInsets(self, notifInfo: notif.userInfo ?? [:], scrollView: self.scrollView, textViewsToCheck: [self.specialInstructions])
    }
    
    func keyboardWillBeHidden(notif: NSNotification) {
        KeyboardHelper.resetScrollInsetsToNormal(self, scrollView: self.scrollView)
    }
}

extension MyInfoViewController: DoneButtonProtocol {
    func doneButtonAction() {
        KeyboardHelper.dismissKeyboard(self)
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
//                formattedString.appendFormat("(%@) ", areaCode)
                formattedString.appendFormat("%@-", areaCode)
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