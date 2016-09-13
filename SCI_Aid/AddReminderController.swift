//
//  AddReminderController.swift
//  SCI_Aid
//
//  Created by Dee on 27/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

//protocol addReminderDelegate{
//    func addReminder(reminder: Reminder)
//}

class AddReminderController: UIViewController {

    
    @IBOutlet var startField: UITextField!
    @IBOutlet var endField: UITextField!
    
    var startTime:NSDate!
    var endTime:NSDate!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
            
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
            
            label.text = "Select a date"
            
            label.textAlignment = NSTextAlignment.Center
            
            let textBtn = UIBarButtonItem(customView: label)
            
            toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
            
            startField.inputAccessoryView = toolBar
            endField.inputAccessoryView = toolBar

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setReminderStartTime(sender: UITextField) {
        startField.text = ""
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryListController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    @IBAction func setReminderEndTime(sender: UITextField) {
        endField.text = ""
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryListController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        if startField.editing {
            startTime = sender.date
            startField.text = dateFormatter.stringFromDate(startTime)
        } else if endField.editing {
            endTime = sender.date
            endField.text = dateFormatter.stringFromDate(endTime)
        }
    }
    
    func donePressed(sender: UIBarButtonItem) {
        if startField.editing {
            startField.resignFirstResponder()
        } else if endField.editing {
            endField.resignFirstResponder()
        }
        
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        if startField.editing {
            startTime = NSDate()
            startField.text = dateformatter.stringFromDate(startTime)
            startField.resignFirstResponder()
            
        } else if endField.editing {
            endTime = NSDate()
            endField.text = dateformatter.stringFromDate(endTime)
            endField.resignFirstResponder()
        }
        
    }
    
    func checkDateValidation() -> Bool{
        if (startField.text == "Start time" || startField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" || endField.text == "End time" || endField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            let messageString: String = "Please select a valid time."
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        if (startTime.compare(endTime) == .OrderedDescending) {
            let messageString: String = "End time should be later than start time."
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
    
    func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Hour], fromDate: startDate, toDate: endDate, options: [])
        
        return components.hour
    }
    
     @IBAction func saveReminder(sender: UIBarButtonItem) {
        if (checkDateValidation()) {
            let dateFormatter = NSDateFormatter()
            //dateFormatter.locale = NSLocale.currentLocale()
            //dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+10:00")
            dateFormatter.dateFormat =  "dd-MM-yyyy HH:mm"
            //print(dateTextField.text)
            //let date = dateFormatter.dateFromString(dateTextField.text!)
            //let enddate = dateFormatter.dateFromString(endDateTextField.text!)
            let timesDifferent = daysBetweenDates(startTime, endDate: endTime)
            let totalCircle = (timesDifferent)/4
            for var n = 0; n <= totalCircle ; n += 1
            {
                let addHours : Double = Double(n)
                let newDate = startTime!.dateByAddingTimeInterval(addHours*60*60*4)
                let reminder = Reminder(deadline: newDate, complete: false, UUID: NSUUID().UUIDString)
                Reminder().addReminder(reminder) // schedule a local notification to persist this item
                self.navigationController?.popViewControllerAnimated(true)
//                print(date!)
//                print(enddate!)
//                print(timesDifferent)
//                print(totalCircle)
                
            }
        }
     }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
