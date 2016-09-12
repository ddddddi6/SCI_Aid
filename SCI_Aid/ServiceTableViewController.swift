//
//  ServiceTableViewController.swift
//  SCI_Aid
//
//  Created by Dee on 10/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Foundation

class ServiceTableViewController: UITableViewController {
    
    var currentCategory: String?
    var index: Int?
    var currentActivity: Activity!
    var activities = [Activity]()
    
    var cellColors = [UIColor.clearColor(), UIColor(red: 106/255.0, green: 84/255.0, blue: 113/255.0, alpha: 1.0)]

    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("activity").child(currentCategory!)

        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        self.title = currentCategory
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        startObservingDB()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download disbility service data from Firebase
    func startObservingDB() {
        
        ref.observeEventType(.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
    
            var newActivities = [Activity]()
            //let result = snapshot.children.accessibilityElementAtIndex(self.index!)
            print(snapshot)
            for activity in snapshot.children {
                if let name = activity.value!["name"] as? String,
                let address = activity.value!["address"] as? String,
                let desc = activity.value!["description"] as? String,
                let email = activity.value!["email"] as? String,
                let freecall = activity.value!["freecall"] as? String,
                let phone = activity.value!["phone"] as? String,
                let website = activity.value!["website"] as? String {
                    let a: Activity = Activity(name: name, address: address, desc: desc, website: website, phone: phone, freecall: freecall, email: email)
                    newActivities.append(a)
                }
            }
            print (newActivities.count)
            self.activities = newActivities
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.description)
        }
    }

    // MARK: - Table view data source

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section)
        {
        case 0: return self.activities.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ServiceTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ServiceTableViewCell
        
        // Configure the cell...
        let a: Activity = self.activities[indexPath.row]
        cell.serviceLabel.text = a.name
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = cellColors[0]
        } else{
            cell.backgroundColor = cellColors[1]
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowServiceDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller: ServiceDetailViewController = segue.destinationViewController as! ServiceDetailViewController
                controller.currentActivity = activities[indexPath.row] 
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
