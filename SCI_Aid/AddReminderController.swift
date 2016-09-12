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
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var changeSwitch: UISwitch!
    @IBOutlet var emptySwitch: UISwitch!
    
    // listen for save button action, save reminder to NSUserDefault
    @IBAction func saveButton(sender: UIButton) {
        let reminder = Reminder(deadline: datePicker.date, complete: false, UUID: NSUUID().UUIDString)
        Reminder().addReminder(reminder) // schedule a local notification to persist this item
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
