//
//  DiaryListController.swift
//  SCI_Aid
//
//  Created by Dee on 29/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

protocol DiaryDelegate {
    func refreshTableView()
}

class DiaryListController: UITableViewController, DiaryDelegate {

    @IBOutlet var endField: UITextField!
    @IBOutlet var startField: UITextField!
    @IBOutlet var greenCount: UILabel?
    @IBOutlet var yellowCount: UILabel?
    @IBOutlet var redCount: UILabel?
    
    var greenCounts: Int?
    var yellowCounts: Int?
    var redCounts: Int?
    var startDate: NSDate!
    var endDate: NSDate!
    var diaries: NSMutableArray

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.diaries = NSMutableArray()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.diaries = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        
        toolBar.tintColor = UIColor.whiteColor()
        
        toolBar.backgroundColor = UIColor.blackColor()
        
        
        let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DiaryListController.tappedToolBarBtn))
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(DiaryListController.donePressed))
        
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startField.text = "Start date"
        endField.text = "End date"
        refreshTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return diaries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "DiaryTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DiaryTableViewCell
        
        // Configure the cell...
        //print(reminders[0].valueForKey("UUID"))
        let d = self.diaries[indexPath.row] as! Diary
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY, HH:mm"
        let date = dateFormatter.stringFromDate(d.diaryDate!)
        cell.dateLabel.text = date
        
        if (d.status == "Green") {
            cell.warningImage.image = UIImage(named: "green")
        } else if (d.status == "Yellow") {
            cell.warningImage.image = UIImage(named: "yellow")
        } else if (d.status == "Red") {
            cell.warningImage.image = UIImage(named: "red")
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            // Delete the row from the data source
            DataManager.dataManager.managedObjectContext!.deleteObject(self.diaries[indexPath.row] as! NSManagedObject)
            //Save the ManagedObjectContext
            do
            {
                try DataManager.dataManager.managedObjectContext!.save()
            }
            catch let error
            {
                print("Could not save Deletion \(error)")
            }
            
            self.diaries = DataManager.dataManager.getDiaryEntries()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        return [delete]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddDiaryEntry") {
            let controller: DiaryDetailViewController = segue.destinationViewController as! DiaryDetailViewController
            controller.delegate = self
        } else if (segue.identifier == "EditDiaryEntry")
        {
            let controller: DiaryDetailViewController = segue.destinationViewController as! DiaryDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            let d: Diary = self.diaries[indexPath.row] as! Diary
            controller.currentDiary = d
            controller.delegate = self
            // Display reminder details screen
        }
    }
    
    // refresh tableview
    func refreshTableView() {
        self.diaries = DataManager.dataManager.getDiaryEntries()
        countColors(self.diaries)
        self.greenCount!.text = ": \(self.greenCounts!)"
        self.yellowCount!.text = ": \(self.yellowCounts!)"
        self.redCount!.text = ": \(self.redCounts!)"
        self.sortDiaryList()
    }
    
    func countColors(diaries: NSMutableArray) {
        greenCounts = 0
        yellowCounts = 0
        redCounts = 0
        for diary in diaries {
            if (diary.status == "Green") {
                greenCounts = greenCounts! + 1
            } else if (diary.status == "Yellow") {
                yellowCounts = yellowCounts! + 1
            } else if (diary.status == "Red") {
                redCounts = redCounts! + 1
            }
        }
    }

    @IBAction func setStartTime(sender: UITextField) {
        startField.text = ""
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryListController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func setEndTime(sender: UITextField) {
        endField.text = ""
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryListController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        if startField.editing {
            startDate = sender.date
            startField.text = dateFormatter.stringFromDate(startDate)
        } else if endField.editing {
            endDate = sender.date
            endField.text = dateFormatter.stringFromDate(endDate)
        }
    }
    
    @IBAction func filterDiaryEntry(sender: UIButton) {
        if (checkDateValidation()) {
            diaries = DataManager.dataManager.getDiaryEntries()
            let newDiaries = NSMutableArray()
            for diary in diaries {
                if (self.isBetweenDates(diary.diaryDate!!, beginDate: startDate, endDate: endDate)) {
                    newDiaries.addObject(diary)
                }
            }
            diaries = newDiaries
            countColors(diaries)
            
            greenCount!.text = ": \(self.greenCounts!)"
            yellowCount!.text = ": \(self.yellowCounts!)"
            redCount!.text = ": \(self.redCounts!)"
            sortDiaryList()
        }
    }
    
    func isBetweenDates(selectedDate: NSDate, beginDate: NSDate, endDate: NSDate) -> Bool
    {
        if selectedDate.compare(beginDate) == .OrderedAscending
        {
            return false
        }
        
        if selectedDate.compare(endDate) == .OrderedDescending
        {
            return false
        }
        return true
    }
    
    func checkDateValidation() -> Bool{
        if (startField.text == "Start date" || startField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" || endField.text == "End date" || endField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            let messageString: String = "Please select a valid date."
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        if (startDate.compare(endDate) == .OrderedDescending) {
            let messageString: String = "End date should be later than start date."
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
    
    func donePressed(sender: UIBarButtonItem) {
        if startField.editing {
            startField.resignFirstResponder()
        } else if endField.editing {
            endField.resignFirstResponder()
        }
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        if startField.editing {
            startDate = NSDate()
            startField.text = dateformatter.stringFromDate(startDate)
            startField.resignFirstResponder()
            
        } else if endField.editing {
            endDate = NSDate()
            endField.text = dateformatter.stringFromDate(endDate)
            endField.resignFirstResponder()
        }
        
    }
    
    @IBAction func viewAllEntries(sender: UIBarButtonItem) {
        refreshTableView()
    }
    
    // sort the diary entry list
    func sortDiaryList() {
        diaries.sortUsingComparator({ (o1: AnyObject!, o2: AnyObject!) -> NSComparisonResult in
            let entry1 = o1 as! Diary
            let entry2 = o2 as! Diary
            return entry2.diaryDate!.compare(entry1.diaryDate!)
        })
        self.tableView.reloadData()
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
