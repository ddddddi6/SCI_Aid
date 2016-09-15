//
//  AppDelegate.swift
//  SCI_Aid
//
//  Created by Dee on 10/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData
import FoldingTabBar
import Firebase
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        FIRAuth.auth()?.signInWithEmail("test@sciaid.com", password: "123456", completion: { (user: FIRUser?, error: NSError?) in
            if error == nil {
                print(user?.email)
            } else {
                print(error?.description)
            }
        })
        FIRDatabase.database().persistenceEnabled = true
        
        DataManager.dataManager.managedObjectContext = self.managedObjectContext
        

    //Override point for customization after application launch.
        
//        if let tabBarController = window?.rootViewController as? YALFoldingTabBarController {
//            
//            //leftBarItems
//            
//            let firstItem = YALTabBarItem(
//                itemImage: UIImage(named: "alarm")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//            
//            let secondItem = YALTabBarItem(
//                itemImage: UIImage(named: "to_do")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//            
//            let thirdItem = YALTabBarItem(
//                itemImage: UIImage(named: "toilet")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//            
//            tabBarController.leftBarItems = [firstItem, secondItem, thirdItem]
//            
//            //rightBarItems
//            
//            let forthItem = YALTabBarItem(
//                itemImage: UIImage(named: "clinic")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//            
//            let fifithItem = YALTabBarItem(
//                itemImage: UIImage(named: "tennis")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//        
//            let sixthItem = YALTabBarItem(
//                itemImage: UIImage(named: "transportation")!,
//                leftItemImage: nil,
//                rightItemImage: nil
//            )
//            
//            tabBarController.rightBarItems = [forthItem, fifithItem, sixthItem]
//            
//            tabBarController.centerButtonImage = UIImage(named: "Menu-2")
//            
//            tabBarController.tabBarView.backgroundColor = UIColor.clearColor()
//            //tabBarController.tabBarView.tabBarColor = UIColor(red: 242/255.0, green: 83/255.0, blue: 65/255.0, alpha: 1.0)
//            tabBarController.tabBarView.tabBarColor = UIColor(red: 19/255.0, green: 170/255.0, blue: 65/255.0, alpha: 1.0)
//            
//            tabBarController.tabBarView.dotColor = UIColor.whiteColor()
//            tabBarController.tabBarView.offsetForExtraTabBarItems = 10
//
//            tabBarController.tabBarView.extraTabBarItemHeight = 55
//        }
        
        //UINavigationBar.appearance().barTintColor = UIColor(red: 23/255.0, green: 123/255.0, blue: 156/255.0, alpha: 1.0)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 159/255.0, green: 122/255.0, blue: 148/255.0, alpha: 1.0)

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        
        
        
        return true
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
//        if application.applicationState == .Active {
//            SystemSoundID soundID;
//            CFBundleRef mainBundle = CFBundleGetMainBundle();
//            CFURLRef ref = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"Voicemail.wav", NULL, NULL);
//            AudioServicesCreateSystemSoundID(ref, &soundID);
//            AudioServicesPlaySystemSound(soundID);
//        }
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.diliu.SCI_Aid" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SCI_Aid", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}


