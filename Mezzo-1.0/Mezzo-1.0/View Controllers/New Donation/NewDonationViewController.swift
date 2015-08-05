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
    
    @IBOutlet var foodTypeButtons: [UIButton]!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeTypePickerView: UIPickerView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: Properties
    
    // TODO: research how to enforce lack of setting capabilities
    /// donation being created (no setting)
    var donation = Donation()
    
    // MARK: Methods
    
    func saveDonation() {
        donation.size = convertSizeToString()
        if !otherTextField.hidden {
            let index = find(donation.foodDescription, "Other")
            donation.foodDescription.removeAtIndex(index!)
            donation.foodDescription.append(otherTextField.text)
        }
    }
    
    func convertSizeToString() -> String {
        var result: String = ""
        
        if let sizeText = sizeTextField.text {
            result += "\(sizeText) "
            if sizeText.toInt() > 1 { // plural
                result += "\(Donation.pluralSizeTypes[sizeTypePickerView.selectedRowInComponent(0)])"
            } else { // singular
                result += "\(Donation.singularSizeTypes[sizeTypePickerView.selectedRowInComponent(0)])"
            }
        }
        
        println(result)
        
        return result
    }
    
    func didTapView() {
        KeyboardHelper.dismissKeyboard(self)
    }
    
    // MARK: keyboard handling
    
//    func keyboardWillShow(notification: NSNotification) {
//        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//            self.view.frame.origin.y -= keyboardFrame.size.height
//            self.bottomConstraint.constant -= 200 // reduce the gap between the bottom of the picker and the keyboard
//        })
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//            self.view.frame.origin.y += keyboardFrame.size.height
//            self.bottomConstraint.constant += 200
//        })
//    }
    
    @IBAction func amountNumberChanged(sender: UITextField) {
        nextButton.enabled = !donation.foodDescription.isEmpty && !sizeTextField.text.isEmpty
            && sizeTextField.text.toInt() > 0
    }
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text wrap for food type button labels
        for button in foodTypeButtons {
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        
        sizeTypePickerView.delegate = self
        sizeTypePickerView.dataSource = self
        
        nextButton.enabled = false
        
        // adjust the view up and down based on whether keyboard is shown
        KeyboardHelper.addDoneToKeyboard(self, textFields: [otherTextField, sizeTextField], textViews: [])
        
        // if users taps outside of the keyboard area, dismiss the keyboard
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        otherTextField.enabled = false
        KeyboardHelper.registerForKeyboardNotifications(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.deregisterFromKeyboardNotifications(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: food type buttons
    @IBAction func foodTypeButtonSelected(sender: AnyObject) {
        let button = sender as! UIButton
        
        if (!button.selected) { // if image is empty checkbox, select
            button.selected = true
            donation.foodDescription.append(button.titleLabel!.text!)
            
            println(donation.foodDescription)
        } else { // if image is filled checkbox, deselect
            button.selected = false
            let index = find(donation.foodDescription, button.titleLabel!.text!)
            donation.foodDescription.removeAtIndex(index!)
            println(donation.foodDescription)
        }
        
        if button.titleLabel!.text == "Other" {
            otherTextField.hidden = !button.selected
        }
        
        // next button shouldn't be enabled unless foodDescription and size are populated
        nextButton.enabled = !donation.foodDescription.isEmpty && !sizeTextField.text.isEmpty
            && sizeTextField.text.toInt() > 0
    }
    
    @IBAction func otherButtonSelected(sender: AnyObject) {
        let button = sender as! UIButton
        otherTextField.enabled = button.selected
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Choose Time":
                saveDonation()
                let destination = segue.destinationViewController as! PickupTimeViewController
                destination.donation = self.donation
            default:
                break
            }
            
        }
    }
}

// MARK: Picker View Delegates

extension NewDonationViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return Donation.pluralSizeTypes[row]
    }
}

extension NewDonationViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Donation.pluralSizeTypes.count
    }
}

// MARK: keyboard

extension NewDonationViewController: KeyboardProtocol {
    func keyboardWillBeHidden(notif: NSNotification) {
        KeyboardHelper.resetScrollInsetsToNormal(self, scrollView: self.scrollView)
    }
    
    func keyboardWasShown(notif: NSNotification) {
        KeyboardHelper.addScrollInsets(self, notifInfo: notif.userInfo ?? [:], scrollView: self.scrollView, textFieldsToCheck: [otherTextField, sizeTextField])
    }
}

extension NewDonationViewController: DoneButtonProtocol {
    func doneButtonAction() {
        KeyboardHelper.dismissKeyboard(self)
        // next button shouldn't be enabled unless foodDescription and size are populated
        nextButton.enabled = !donation.foodDescription.isEmpty && !sizeTextField.text.isEmpty
            && sizeTextField.text.toInt() > 0
    }
}