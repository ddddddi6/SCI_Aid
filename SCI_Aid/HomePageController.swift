//
//  HomePageController.swift
//  SCI_Aid
//
//  Created by Dee on 15/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

protocol ReminderDelegate {
    func pushAlert()
}

class HomePageController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReminderDelegate{

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var initialView: UIView!
    
    var deadline: NSDate!
    var reminders: [Reminder] = []
    var createdDiary: Diary!
    var interval: Double?
    var newDate: NSDate?
    var date: String?
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    // delete all completed reminder entries
    @IBAction func deleteAllReminders(sender: UIBarButtonItem) {
        let messageString: String = "Do you want to delete all completed entries?"
        // Setup an alert to warn user
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
            UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
            for reminder in self.reminders {
                if reminder.complete == true {
                    let index = self.reminders.indexOf(reminder)
                    let reminder = self.reminders.removeAtIndex(index!)
                    self.tableView.reloadData()
                    Reminder.currentReminder.removeReminder(reminder)
                }
            }
            self.refreshList()
            self.refreshTitle()
            self.displayNoReminderMessage()
        }))
        print(reminders.count)
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // add a new reminder entry
    @IBAction func setReminder(sender: UIButton) {
        self.performSegueWithIdentifier("addReminderSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check whether the application is first launch, if it is first launch then display tutorial pages
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            print("first launch.")
            if let pageViewController =
                storyboard?.instantiateViewControllerWithIdentifier("WalkthroughController")
                    as? WalkthroughPageViewController {
                presentViewController(pageViewController, animated: true, completion:nil)
            }
        }
        
        let font = UIFont(name: "Helvetica", size: 14)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:font!], forState: .Normal)
        
        refreshList()
        refreshTitle()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        self.infoLabel.backgroundColor = UIColor(red: 106/255.0, green: 84/255.0, blue: 113/255.0, alpha: 1.0)
        displayNoReminderMessage()
        
        Reminder.currentReminder.delegate = self

        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
        refreshTitle()
        displayNoReminderMessage()
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
    }
    
    // show button when there is no reminder
    func displayNoReminderMessage() {
        if (reminders.count == 0) {
            tableView.hidden = true
            initialView.hidden = false
            self.infoLabel.hidden = true
        } else {
            tableView.hidden = false
            initialView.hidden = true
            self.infoLabel.hidden = false
        }
    }
    
    @IBAction func addReminderEntry(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addReminderSegue", sender: self)
    }
    
    func checkCompletionStatus() -> Bool {
        for reminder in reminders {
            if !reminder.complete! {
                return true
            } else {
                continue
            }
        }
        return false
    }
    
    // refresh reminder entries table view
    func refreshList() {
        reminders = Reminder.currentReminder.getAllReminders()
        if reminders.count == 0 {
            self.navigationItem.leftBarButtonItem?.enabled = false
        } else {
            self.navigationItem.leftBarButtonItem?.enabled = true
        }
        reminders = reminders.sort({ ($0.deadline)!.compare($1.deadline!) == .OrderedDescending })
        reminders = reminders.sort({ !$0.complete! && $1.complete! })
        
        if checkCompletionStatus() {
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        tableView.reloadData()
    }
    
    // refresh information label
    func refreshTitle() {
        for reminder in reminders {
            if reminder.complete == false {
                self.interval = reminder.interval
            }
        }
        
        if interval != nil {
            self.infoLabel.text = " Next reminder will be in " + String(Int(self.interval!)) + " hours"
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ReminderTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell
        
        
        cell.selectionStyle = .None
        // Configure the cell...
        //print(reminders[0].valueForKey("UUID"))
        let r = self.reminders[indexPath.row] as Reminder
        
        if (r.complete!) {
            cell.selectionStyle = .None
        } else {
            cell.selectionStyle = .Default
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY, HH:mm"
        let date = dateFormatter.stringFromDate(r.deadline!)
        cell.dateLabel?.text = date
        
        if (r.deadline?.compare(NSDate()) == NSComparisonResult.OrderedAscending) {
            cell.dateLabel?.textColor = UIColor.redColor()
            cell.completionLabel?.textColor = UIColor.redColor()
            cell.statusLabel?.textColor = UIColor.redColor()
        }
        if (r.complete == true) {
            cell.completionLabel?.text = "Yes"
            cell.dateLabel?.textColor = UIColor.lightGrayColor()
            cell.completionLabel?.textColor = UIColor.lightGrayColor()
            cell.statusLabel?.textColor = UIColor.lightGrayColor()
            cell.clockImage?.image = UIImage(named: "clock_bw")
        } else {
            cell.completionLabel?.text = "No"
            cell.dateLabel?.textColor = UIColor.whiteColor()
            cell.completionLabel?.textColor = UIColor.whiteColor()
            cell.statusLabel?.textColor = UIColor.whiteColor()
            cell.clockImage?.image = UIImage(named: "clock")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let r = self.reminders[indexPath.row] as Reminder
        // add to self.selectedItems
        if (!r.complete!) {
            self.performSegueWithIdentifier("editReminderSegue", sender: nil)
        }
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var titleLabel: String!
        if (self.reminders[indexPath.row].complete!) {
            titleLabel = "Uncompleted"
        } else {
            titleLabel = "Completed"
        }
        let complete = UITableViewRowAction(style: .Normal, title: titleLabel) { action, index in
            let reminder = self.reminders[indexPath.row]
            if (titleLabel == "Completed") {
                reminder.complete = true
                self.deadline = reminder.deadline
                if (self.checkDiaryTime(reminder)) {
                    let messageString: String = "Do you want to create a diary entry?"
                    // Setup an alert to warn user
                    // UIAlertController manages an alert instance
                    let alertController = UIAlertController(title: "Message", message: messageString, preferredStyle:
                        UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
                        if (reminder.deadline?.timeIntervalSinceNow > 0) {
                            let messageString: String = "Sorry, the diary entry time cannot be late than current time"
                            // Setup an alert to warn user
                            // UIAlertController manages an alert instance
                            let alertController = UIAlertController(title: "Message", message: messageString, preferredStyle:
                                UIAlertControllerStyle.Alert)
                            
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        } else {
                            self.performSegueWithIdentifier("reminderToDiary", sender: self)
                        }
                    }))
                    alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    let messageString: String = "You have already created a diary entry."
                    // Setup an alert to warn user
                    // UIAlertController manages an alert instance
                    let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                        UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "View Entry", style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
                        self.performSegueWithIdentifier("reminderToDiary", sender: self)
                    }))
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action: UIAlertAction!) in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                // once the reminder entry is marked as completed, then add a new reminder entry
                self.addNewReminder(reminder)
            } else {
                reminder.complete = false
                for savedReminder in self.reminders {
                    if savedReminder.deadline?.compare(reminder.deadline!) == .OrderedDescending {
                        Reminder.currentReminder.removeReminder(savedReminder)
                    }
                }
                tableView.reloadData()
                self.refreshTitle()
            }
            Reminder.currentReminder.editReminder(reminder)
            self.refreshList()
        }
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            let reminder = self.reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            Reminder.currentReminder.removeReminder(reminder)
            self.refreshTitle()
            self.displayNoReminderMessage()
            self.refreshList()
            //self.navigationItem.rightBarButtonItem!.enabled = true
        }
        if (self.reminders[indexPath.row].deadline?.timeIntervalSinceNow > 0 && self.reminders[indexPath.row].complete == false) {
            return [delete]
        } else if (self.reminders[indexPath.row].deadline?.timeIntervalSinceNow < 0 && self.reminders[indexPath.row].complete == true) {
             return [delete]
        }
        else {
            return [delete, complete]
        }
    }
    
    // check whether the user has already generated a diary entry for this reminder entry
    func checkDiaryTime(reminder: Reminder) -> Bool {
        let diaries = DataManager.dataManager.getDiaryEntries()
        for diary in diaries {
            let d = diary as! Diary
            print(dateWithOutTime(reminder.deadline))
            print(dateWithOutTime(d.diaryDate))
            if dateWithOutTime(reminder.deadline) == dateWithOutTime(d.diaryDate) {
                self.createdDiary = diary as! Diary
                return false
            }
        }
        return true
    }
    
    // get rid of seconds from time
    func dateWithOutTime(datDate: NSDate?) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: datDate!)
        return calendar.dateFromComponents(components)!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if (segue.identifier == "reminderToDiary") {
            let controller: DiaryDetailViewController = segue.destinationViewController as! DiaryDetailViewController
            if createdDiary == nil {
                controller.currentDateofDiary = deadline
            } else {
                controller.currentDiary = createdDiary
            }
        } else if (segue.identifier == "editReminderSegue") {
            let controller: AddReminderController = segue.destinationViewController as! AddReminderController
            let indexPath = tableView.indexPathForSelectedRow!
            let r: Reminder = self.reminders[indexPath.row]
            controller.reminder = r
        }
    }

    // pop up alert message to notify user when the application is active
    func pushAlert() {
        let messageString: String = "It's time to empty bladder"
        // Setup an alert to warn user
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
            UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // add a new reminder
    func addNewReminder(previousReminder: Reminder) {
        newDate = NSDate().dateByAddingTimeInterval(60*60*previousReminder.interval!)
        let reminder = Reminder(deadline: newDate!, complete: false, UUID: NSUUID().UUIDString, interval: previousReminder.interval!)
        Reminder.currentReminder.addReminder(reminder) // schedule a local notification to persist this item
        refreshList()
        refreshTitle()
    }
}
