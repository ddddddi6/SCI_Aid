//
//  AddReminderController.swift
//  SCI_Aid
//
//  Created by Dee on 27/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class AddReminderController: UIViewController {

    @IBOutlet var intervalSegment: UISegmentedControl!
    @IBOutlet var startField: UITextField!
    @IBOutlet var endField: UITextField!
    
    var startTime: NSDate!
    var endTime: NSDate!
    var interval: Double!
    
    var reminder: Reminder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reminder == nil {
            // new a reminder entry
            self.intervalSegment.selectedSegmentIndex = 0
            self.interval = 2
            self.title = "New Reminder Entry"
        } else {
            // edit a reminder entry
            showReminderDetails()
            self.title = "Edit Reminder Entry"
        }
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        // define datepicker view
            let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
            
            toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
            
            toolBar.barStyle = UIBarStyle.BlackTranslucent
            
            toolBar.tintColor = UIColor.whiteColor()
            
            toolBar.backgroundColor = UIColor.blackColor()
            
            
            let todayBtn = UIBarButtonItem(title: "Now", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddReminderController.tappedToolBarBtn))
            
            let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(AddReminderController.donePressed))
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
            
            label.font = UIFont(name: "Helvetica", size: 12)
            
            label.backgroundColor = UIColor.clearColor()
            
            label.textColor = UIColor.whiteColor()
            
            label.text = "Select a time"
            
            label.textAlignment = NSTextAlignment.Center
            
            let textBtn = UIBarButtonItem(customView: label)
            
            toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
            
            startField.inputAccessoryView = toolBar
            //endField.inputAccessoryView = toolBar

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // display reminder entry detail for users to view and edit
    func showReminderDetails() {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        startField.text = dateFormatter.stringFromDate(reminder!.deadline!)
        
        startTime = reminder?.deadline
        
        switch Int((reminder?.interval)!)
        {
            case 2:
                intervalSegment.selectedSegmentIndex = 0
                interval = 2
                break
            case 3:
                intervalSegment.selectedSegmentIndex = 1
                interval = 3
                break
            case 4:
                intervalSegment.selectedSegmentIndex = 2
                interval = 4
                break
            case 5:
                intervalSegment.selectedSegmentIndex = 3
                interval = 5
                break
            default:
                break
        }
    }
    
    // set reminder start time
    @IBAction func setReminderTime(sender: UITextField) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        startTime = NSDate()
        startField.text = dateFormatter.stringFromDate(startTime)
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        datePickerView.minimumDate = NSDate()
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryListController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        if startField.editing {
            startTime = sender.date
            startField.text = dateFormatter.stringFromDate(startTime)
        }
    }
    
    func donePressed(sender: UIBarButtonItem) {
        if startField.editing {
            startField.resignFirstResponder()
        }
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        if startField.editing {
            startTime = NSDate()
            startField.text = dateformatter.stringFromDate(startTime)
            startField.resignFirstResponder()
            
        }
    }
    
    // check seleted time validation
    func checkDateValidation() -> Bool{
        if (startField.text == "Start time" || startField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            let messageString: String = "Please select a valid time."
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                            UIAlertControllerStyle.Alert)
            
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
                self.presentViewController(alertController, animated: true, completion: nil)
                return false

        } else {
            return true
        }

    }
    
    // save reminder entry
     @IBAction func saveReminder(sender: UIBarButtonItem) {
        if (checkDateValidation()) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat =  "dd-MM-yyyy HH:mm"
        
        if reminder == nil {
            let reminder = Reminder(deadline: startTime, complete: false, UUID: NSUUID().UUIDString, interval: interval)
            Reminder.currentReminder.addReminder(reminder) // schedule a local notification to persist this item
        } else {
            reminder?.deadline = startTime
            reminder?.interval = interval
            Reminder.currentReminder.editReminder(reminder!)
        }
            self.navigationController?.popViewControllerAnimated(true)
        }
     }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // listen to interval segment value change
    @IBAction func setInterval(sender: UISegmentedControl) {
        switch intervalSegment.selectedSegmentIndex {
        case 0:
            self.interval = 2
            break
        case 1:
            self.interval = 3
            break
        case 2:
            self.interval = 4
            break
        case 3:
            self.interval = 5
            break
        default:
            break
        }
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
