//
//  ReminderListController.swift
//  SCI_Aid
//
//  Created by Dee on 27/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ReminderListController: UITableViewController {

    @IBOutlet var initialView: UIView!
    @IBOutlet var infoLabel: UILabel!
    
    var reminders: [Reminder] = []
    
    @IBAction func createNewReminder(sender: UIButton) {
        self.performSegueWithIdentifier("addReminderSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTitle()
        refreshList()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)        
        displayNoReminderMessage()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func tabBarDidSelectExtraRightItem(tabBar: UITabBarController) {
        self.performSegueWithIdentifier("addReminderSegue", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
        refreshTitle()
        displayNoReminderMessage()
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayNoReminderMessage() {
        let cellIdentifier = "ReminderTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ReminderTableViewCell
        
        if (reminders.count == 0) {
            cell.hidden = true
            initialView.hidden = false
            self.infoLabel.hidden = true
        } else {
            cell.hidden = false
            initialView.hidden = true
            self.infoLabel.hidden = false
        }

    }
    
    func refreshList() {
        reminders = Reminder().getAllReminders()
        tableView.reloadData()
    }
    
    func refreshTitle() {
        if (reminders.count == 0) {
            self.infoLabel.text = "  There is no reminder"
        } else if (reminders.count == 1) {
            self.infoLabel.text = "  Here is " + String(reminders.count) + " Reminder"
        } else {
            self.infoLabel.text = "  Here Are " + String(reminders.count) + " Reminders"
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ReminderTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell
        
        // Configure the cell...
        //print(reminders[0].valueForKey("UUID"))
        let r = self.reminders[indexPath.row] as Reminder
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY, HH:mm"
        let date = dateFormatter.stringFromDate(r.deadline!)
        cell.dateLabel.text = date
        
        if (r.complete == true) {
            cell.completionLabel.text = "Yes"
        } else {
            cell.completionLabel.text = "No"
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        else{
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
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
            self.refreshTitle()
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
        return [delete, complete]
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "editReminderSegue")
//        {
//            let controller: ReminderDetailViewController = segue.destinationViewController as! ReminderDetailViewController
//            let indexPath = tableView.indexPathForSelectedRow!
//            
//            let r: Reminder = self.reminders[indexPath.row] 
//            controller.currentReminder = r
//            // Display reminder details screen
//        }
//    }
    
    @IBAction func displayAboutView(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showAboutSegue", sender: nil)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
