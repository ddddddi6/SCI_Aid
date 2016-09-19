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

class HomePageController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReminderDelegate {

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var initialView: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    
    var deadline: NSDate!
    var reminders: [Reminder] = []
    var createdDiary: Diary!
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    @IBAction func setReminder(sender: UIButton) {
        self.performSegueWithIdentifier("addReminderSegue", sender: self)
    }
    
    @IBAction func displayAbourScreen(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showAboutSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        refreshTitle()
        refreshList()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        //tableView.registerClass(ReminderTableViewCell.self, forCellReuseIdentifier: "ReminderTableViewCell")
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
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
    
    func tabBarDidSelectExtraRightItem(tabBar: UITabBarController) {
        self.performSegueWithIdentifier("addReminderSegue", sender: nil)
    }
    
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
    
    func refreshList() {
        reminders = Reminder().getAllReminders()
        reminders = reminders.sort({ ($0.deadline)!.compare($1.deadline!) == .OrderedAscending })
        tableView.reloadData()
    }
    
    func refreshTitle() {
        if (reminders.count == 0) {
            self.infoLabel.text = "  There is no reminder"
        } else if (reminders.count == 1) {
            self.infoLabel.text = "  There is " + String(reminders.count) + " Reminder"
        } else {
            self.infoLabel.text = "  There Are " + String(reminders.count) + " Reminders"
        }
    }
    
    @IBAction func filterReminderList(sender: UIButton) {
        for reminder in reminders {
            if reminder.completion == true {
                let reminder = self.reminders.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                Reminder().removeReminder(reminder)
            }
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
                    let messageString: String = "Do you want to create a diary?"
                    // Setup an alert to warn user
                    // UIAlertController manages an alert instance
                    let alertController = UIAlertController(title: "Message", message: messageString, preferredStyle:
                        UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
                        self.performSegueWithIdentifier("reminderToDiary", sender: self)
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
            } else {
                reminder.complete = false
            }
            tableView.reloadData()
            Reminder().editReminder(reminder)
        }
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            let reminder = self.reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            Reminder().removeReminder(reminder)
            //self.refreshTitle()
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        return [delete, complete]
    }
    
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
        }
    }

    func pushAlert() {
        let messageString: String = "It's time to empty bladder"
        // Setup an alert to warn user
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
            UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
