//
//  DataManager.swift
//  SCI_Aid
//
//  Created by Dee on 11/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let dataManager = DataManager()
    
    var managedObjectContext: NSManagedObjectContext?
    
    // save data to CoreData
    func saveData() {
        if self.managedObjectContext!.hasChanges {
            do {
                try self.managedObjectContext!.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // get diary list from coredata
    func getDiaryEntries() -> NSMutableArray {
        var currentDiary: NSMutableArray!
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Diary", inManagedObjectContext:
            self.managedObjectContext!)
        fetchRequest.entity = entityDescription
        
        var result = NSArray?()
        do
        {
            result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            if result!.count == 0
            {
                currentDiary = []
            }
            else
            {
                currentDiary = NSMutableArray(array: result!)
            }
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
        return currentDiary
    }
    
}
