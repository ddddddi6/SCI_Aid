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

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var goodImage: UIImageView!
    @IBOutlet var goodLabel: UILabel!
    @IBOutlet var volumeSegment: UISegmentedControl!
    @IBOutlet var dysreflexiaSwitch: UISwitch!
    @IBOutlet var painfulSwitch: UISwitch!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var blockedSwitch: UISwitch!
    @IBOutlet var toiletSwitch: UISwitch!
    @IBOutlet var smellySwitch: UISwitch!
    @IBOutlet var catheterSwitch: UISwitch!
    
    @IBAction func isOk(sender: UIButton) {
        if (currentDiary == nil) {
            currentDiary = (NSEntityDescription.insertNewObjectForEntityForName("Diary",
                inManagedObjectContext: DataManager.dataManager.managedObjectContext!) as? Diary)!
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = dateFormatter.dateFromString(self.dateLabel.text!)
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
        delegate.refreshTableView()
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func notOk(sender: UIButton) {
        statusView.hidden = true
        problemView.hidden = false
    }
    
    @IBAction func cacelAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // listen for save button action, save diary to NSUserDeafualt
    @IBAction func saveDiary(sender: UIButton) {
        if (currentDiary == nil) {
            currentDiary = (NSEntityDescription.insertNewObjectForEntityForName("Diary",
                inManagedObjectContext: DataManager.dataManager.managedObjectContext!) as? Diary)!
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
        let date = dateFormatter.dateFromString(self.dateLabel.text!)
        let diaryDate = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Year,
                value: 1,
                toDate: date!,
                options: []
        )

        currentDiary.diaryDate = diaryDate
        currentDiary.condition = false
        currentDiary.hasCatheter = checkState(catheterSwitch)
        currentDiary.hasToilet = checkState(toiletSwitch)
        currentDiary.isBlocked = checkState(blockedSwitch)
        currentDiary.isDysreflexia = checkState(dysreflexiaSwitch)
        currentDiary.isLittle = littleVolume
        currentDiary.isMuch = muchVolume
        currentDiary.isPainful = checkState(painfulSwitch)
        currentDiary.isSmelly = checkState(smellySwitch)
        if (checkState(dysreflexiaSwitch) == false && checkState(painfulSwitch) == false && checkState(smellySwitch) == false) {
            currentDiary.status = "Yellow"
        } else {
            currentDiary.status = "Red"
        }
        
        DataManager.dataManager.saveData()
        delegate.refreshTableView()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.masksToBounds = true
        
        if currentDiary == nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
            let date = dateFormatter.stringFromDate(NSDate())
            self.dateLabel.text = date
            statusView.hidden = false
            problemView.hidden = true
            goodLabel.hidden = true
            goodImage.hidden = true
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY HH:mm"
            let date = dateFormatter.stringFromDate(self.currentDiary.diaryDate!)
            self.dateLabel.text = date
            statusView.hidden = true
            if currentDiary.condition == true {
                goodLabel.hidden = false
                goodImage.hidden = false
                problemView.hidden = true
            } else {
                goodLabel.hidden = true
                goodImage.hidden = true
                problemView.hidden = false
                showDiaryDetails()
            }
            
        }
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            volumeSegment.selectedSegmentIndex = 0
        } else {
            volumeSegment.selectedSegmentIndex = 1
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
            littleVolume = true
            muchVolume = false
            break
        case 1:
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
