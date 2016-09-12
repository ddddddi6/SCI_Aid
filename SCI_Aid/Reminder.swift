//
//  Reminder.swift
//  SCI_Aid
//
//  Created by Dee on 27/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class Reminder: NSObject {
    var deadline: NSDate?
    var complete: Bool?
    var UUID: String!
    
    private let ITEMS_KEY = "p"
    
    override init()
    {
        self.deadline = nil
        self.complete = false
        self.UUID = "Unknown"
        // Default intialization of each variables
    }
    
    init(deadline: NSDate, complete: Bool, UUID: String)
    {
        self.deadline = deadline
        self.complete = complete
        self.UUID = UUID
        // Custome initialization of each variables
    }
    
    func getAllReminders() -> [Reminder] {
        let todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let reminders = Array(todoDictionary.values)
        return reminders.map({Reminder(deadline: $0["deadline"] as! NSDate, complete: $0["complete"] as! Bool,  UUID: $0["UUID"] as! String)})
    }
    
    func addReminder(reminder: Reminder) {
        
        var reminders = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary()
        reminders[reminder.UUID] = ["deadline": reminder.deadline!, "complete": reminder.complete!, "UUID": reminder.UUID]
        NSUserDefaults.standardUserDefaults().setObject(reminders, forKey: ITEMS_KEY)
        
        pushNotification(reminder)
    }
    
    func removeReminder(reminder: Reminder) {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == reminder.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        
        if var reminders = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
            reminders.removeValueForKey(reminder.UUID)
            NSUserDefaults.standardUserDefaults().setObject(reminders, forKey: ITEMS_KEY) // save/overwrite todo item list
        }
    }

    func editReminder(reminder: Reminder) {
        if var reminders = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY)  {
            //reminders.removeValueForKey(reminder.UUID)
            reminders[reminder.UUID] = ["deadline": reminder.deadline!, "complete": reminder.complete!, "UUID": reminder.UUID]
            NSUserDefaults.standardUserDefaults().setObject(reminders, forKey: ITEMS_KEY) // save/overwrite todo item list
        }
        pushNotification(reminder)
    }
    
    func pushNotification(reminder: Reminder) {
        if (!reminder.complete!) {
            // Notify the user when they need to empty bladder
            let message = "It's time to empty bladder"
            
            // create a corresponding local notification
            let notification = UILocalNotification()
            notification.alertBody = message
            notification.alertAction = "open"
            notification.fireDate = reminder.deadline
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["title": "bladder issue", "UUID": reminder.UUID]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        } else {
            let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
            guard scheduledNotifications != nil else {return} // Nothing to remove, so return
            
            for notification in scheduledNotifications! { // loop through notifications...
                if (notification.userInfo!["UUID"] as! String == reminder.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                    UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                    break
                }
            }
        }
    }
}
