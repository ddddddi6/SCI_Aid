//
//  ReminderDetailViewController.swift
//  SCI_Aid
//
//  Created by Dee on 28/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ReminderDetailViewController: UIViewController {
    
    var currentReminder: Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        let date = dateFormatter.stringFromDate(self.currentReminder!.deadline!)
        self.dateLabel.text = date
        
        diaryButton.hidden = true
        
        if (self.currentReminder!.complete == false) {
            statusSwitch.setOn(false, animated:true)
        } else {
            statusSwitch.setOn(true, animated:true)
        }

        statusSwitch.addTarget(self, action: #selector(ReminderDetailViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        if statusSwitch.on {
            issueView.hidden = false
        } else {
            issueView.hidden = true
        }
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateChanged(switchState: UISwitch) {
        if statusSwitch.on {
            self.currentReminder?.complete = true
            self.issueView.hidden = false
        } else {
            self.currentReminder?.complete = false
            self.issueView.hidden = true
        }
        
        Reminder().editReminder(self.currentReminder)
        
        // Listen to the UISwitch state changes
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "createDiarySegue")
        {
            let controller: DiaryDetailViewController = segue.destinationViewController as! DiaryDetailViewController
            
            controller.currentDateofDiary = currentReminder.deadline
            // Display reminder details screen
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
