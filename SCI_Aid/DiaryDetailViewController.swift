//
//  DiaryDetailViewController.swift
//  SCI_Aid
//
//  Created by Dee on 29/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

class DiaryDetailViewController: UIViewController {
    
    var currentDateofDiary: NSDate!
    var currentDiary: Diary!
    var delegate: DiaryDelegate!
    var littleVolume: Bool!
    var muchVolume: Bool!
    
    @IBOutlet var statusView: UIView!
    @IBOutlet var problemView: UIView!

    @IBOutlet var statusButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var goodImage: UIImageView!
    @IBOutlet var goodLabel: UILabel!
    @IBOutlet var volumeSegment: UISegmentedControl!
    @IBOutlet var dysreflexiaSwitch: UISwitch!
    @IBOutlet var painfulSwitch: UISwitch!
    @IBOutlet var blockedSwitch: UISwitch!
    @IBOutlet var toiletSwitch: UISwitch!
    @IBOutlet var smellySwitch: UISwitch!
    @IBOutlet var catheterSwitch: UISwitch!
    
    @IBOutlet var dateFiled: UITextField!
    
    
    @IBAction func isOk(sender: UIButton) {
        if (currentDateofDiary.timeIntervalSinceNow > 0) {
            let messageString: String = "The date cannot be later than current time."
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Message", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
        if (currentDiary == nil) {
            currentDiary = (NSEntityDescription.insertNewObjectForEntityForName("Diary",
                inManagedObjectContext: DataManager.dataManager.managedObjectContext!) as? Diary)!
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = dateFormatter.dateFromString(self.dateFiled.text!)
        currentDiary.diaryDate = date
        currentDiary.condition = true
        currentDiary.hasCatheter = false
        currentDiary.hasToilet = false
        currentDiary.isBlocked = false
        currentDiary.isDysreflexia = false
        currentDiary.isLittle = false
        currentDiary.isMuch = false
        currentDiary.isPainful = false
        currentDiary.isSmelly = false
        currentDiary.status = "Green"
        
        DataManager.dataManager.saveData()
        if currentDateofDiary == nil {
            delegate.refreshTableView()
        }
        self.navigationController?.popViewControllerAnimated(true)
        }
    }

    @IBAction func notOk(sender: UIButton) {
        statusView.hidden = true
        problemView.hidden = false
    }
    
    @IBAction func cacelAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // listen for save button action, save diary to core data
    @IBAction func saveDiary(sender: UIButton) {
        if (currentDateofDiary.timeIntervalSinceNow > 0) {
            let messageString: String = "The date cannot be later than current time."
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Message", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
        if (currentDiary == nil) {
            currentDiary = (NSEntityDescription.insertNewObjectForEntityForName("Diary",
                inManagedObjectContext: DataManager.dataManager.managedObjectContext!) as? Diary)!
        }

        currentDiary.diaryDate = currentDateofDiary
        currentDiary.condition = false
        currentDiary.hasCatheter = checkState(catheterSwitch)
        currentDiary.hasToilet = checkState(toiletSwitch)
        currentDiary.isBlocked = checkState(blockedSwitch)
        currentDiary.isDysreflexia = checkState(dysreflexiaSwitch)
        currentDiary.isLittle = littleVolume
        currentDiary.isMuch = muchVolume
        currentDiary.isPainful = checkState(painfulSwitch)
        currentDiary.isSmelly = checkState(smellySwitch)
        
        if (volumeSegment.selectedSegmentIndex == 0 && !(checkState(dysreflexiaSwitch)) && !(checkState(painfulSwitch)) && !(checkState(smellySwitch)) && !(checkState(toiletSwitch)) && !(checkState(blockedSwitch)) && !(checkState(catheterSwitch))) {
            currentDiary.status = "Green"
            currentDiary.condition = true
        } else if (checkState(dysreflexiaSwitch) || checkState(painfulSwitch) || checkState(smellySwitch)) {
            currentDiary.status = "Red"
        } else {
            currentDiary.status = "Yellow"
        }
        DataManager.dataManager.saveData()
        if currentDateofDiary == nil {
            delegate.refreshTableView()
        }
        self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.masksToBounds = true
        statusButton.layer.cornerRadius = 5
        statusButton.layer.masksToBounds = true
        
        if currentDiary == nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
            if currentDateofDiary == nil {
                currentDateofDiary = NSDate()
            }
            let date = dateFormatter.stringFromDate(currentDateofDiary)
            self.dateFiled.text = date
            statusView.hidden = false
            problemView.hidden = true
            goodLabel.hidden = true
            goodImage.hidden = true
            statusButton.hidden = true
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
            let date = dateFormatter.stringFromDate(self.currentDiary.diaryDate!)
            currentDateofDiary = self.currentDiary.diaryDate!
            self.dateFiled.text = date
            statusView.hidden = true
            if currentDiary.condition == true {
                goodLabel.hidden = false
                goodImage.hidden = false
                statusButton.hidden = false
                problemView.hidden = true
            } else {
                goodLabel.hidden = true
                goodImage.hidden = true
                statusButton.hidden = true
                problemView.hidden = false
                showDiaryDetails()
            }
  
        }
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        
        toolBar.tintColor = UIColor.whiteColor()
        
        toolBar.backgroundColor = UIColor.blackColor()
        
        
        let todayBtn = UIBarButtonItem(title: "Now", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DiaryListController.tappedToolBarBtn))
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(DiaryListController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clearColor()
        
        label.textColor = UIColor.whiteColor()
        
        label.text = "Select a time"
        
        label.textAlignment = NSTextAlignment.Center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        
        dateFiled.inputAccessoryView = toolBar

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeStatus(sender: UIButton) {
        goodImage.hidden = true
        goodLabel.hidden = true
        statusButton.hidden = true
        statusView.hidden = false
    }
    
    func showDiaryDetails() {
        if (self.currentDiary!.isDysreflexia == true) {
            dysreflexiaSwitch.setOn(true, animated:true)
        } else {
            dysreflexiaSwitch.setOn(false, animated:true)
        }
        
        if (self.currentDiary!.isPainful == true) {
            painfulSwitch.setOn(true, animated:true)
        } else {
            painfulSwitch.setOn(false, animated:true)
        }
        
        if (self.currentDiary!.isSmelly == true) {
            smellySwitch.setOn(true, animated:true)
        } else {
            smellySwitch.setOn(false, animated:true)
        }
        
        if (self.currentDiary!.isLittle == true) {
            volumeSegment.selectedSegmentIndex = 1
        } else if (self.currentDiary!.isMuch == true) {
            volumeSegment.selectedSegmentIndex = 2
        } else {
            volumeSegment.selectedSegmentIndex = 0
        }
        
        if (self.currentDiary!.isBlocked == true) {
            blockedSwitch.setOn(true, animated:true)
        } else {
            blockedSwitch.setOn(false, animated:true)
        }
        
        if (self.currentDiary!.hasCatheter == true) {
            catheterSwitch.setOn(true, animated:true)
        } else {
            catheterSwitch.setOn(false, animated:true)
        }
        
        if (self.currentDiary!.hasToilet == true) {
            toiletSwitch.setOn(true, animated:true)
        } else {
            toiletSwitch.setOn(false, animated:true)
        }
    }
    
    func checkState(switchState: UISwitch) -> Bool{
        var flag: Bool
        if switchState.on {
            flag = true
        } else {
            flag = false
        }
        return flag
    }
    
    @IBAction func checkVolume(sender: UISegmentedControl) {
        switch volumeSegment.selectedSegmentIndex
        {
            case 0:
                littleVolume = false
                muchVolume = false
                break
            case 1:
                littleVolume = true
                muchVolume = false
                break
            case 2:
                muchVolume = true
                littleVolume = false
                break
            default:
                break;
        }
    }
    
    // share the screenshot via other applications
    @IBAction func shareScreenshot(sender: UIBarButtonItem) {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        
        let scale = UIScreen.mainScreen().scale
        
        // get the screenshot of current view
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func selectDate(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.maximumDate = NSDate()
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(DiaryDetailViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        currentDateofDiary = sender.date
        dateFiled.text = dateformatter.stringFromDate(currentDateofDiary)

    }
    
    func donePressed(sender: UIBarButtonItem) {
        dateFiled.resignFirstResponder()
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateFormat = "dd-MM-YYYY HH:mm"
        
        currentDateofDiary = NSDate()
        dateFiled.text = dateformatter.stringFromDate(currentDateofDiary)
        dateFiled.resignFirstResponder()
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
