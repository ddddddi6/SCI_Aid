//
//  ServiceDetailViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ServiceDetailViewController: UIViewController {

    @IBOutlet var descLabel: UILabel!
    
    @IBOutlet var addressButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var freecallButton: UIButton!
    
    var currentActivity: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Disability Service"

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        nameLabel.text = " " + currentActivity.name!
        
        addressButton.setTitle(currentActivity.address, forState: .Normal)
        addressButton.titleLabel?.numberOfLines = 0
        addressButton.titleLabel?.lineBreakMode = .ByWordWrapping
        addressButton.contentHorizontalAlignment = .Left
        
        descLabel.text = currentActivity.desc
        
        phoneButton.contentHorizontalAlignment = .Left
        phoneButton.setTitle(currentActivity.phone, forState: .Normal)
        
        websiteButton.titleLabel?.numberOfLines = 0
        websiteButton.titleLabel?.lineBreakMode = .ByWordWrapping
        websiteButton.contentHorizontalAlignment = .Left
        websiteButton.contentVerticalAlignment = .Top
        websiteButton.setTitle(currentActivity.website, forState: .Normal)
        
        emailLabel.text = currentActivity.email
        
        freecallButton.contentHorizontalAlignment = .Left
        freecallButton.setTitle(currentActivity.freecall, forState: .Normal)
        
        if addressButton.titleLabel!.text == "N.A." {
            addressButton.enabled = false
        }
        if phoneButton.titleLabel!.text == "N.A." {
            phoneButton.enabled = false
        }
        if websiteButton.titleLabel!.text == "N.A." {
            websiteButton.enabled = false
        }
        if freecallButton.titleLabel!.text == "N.A." {
            freecallButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // display service location on map
    @IBAction func navigateService(sender: UIButton) {
        self.performSegueWithIdentifier("showLocationSegue", sender: self)
    }
    
    // call the service phone number
    @IBAction func callPhoneNumber(sender: UIButton) {
        let number = self.phoneButton.titleLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(number)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    // open the service website in safari
    @IBAction func openWebsite(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.websiteButton.titleLabel!.text!)!)
    }
    
    // call service freecall number
    @IBAction func callFreecall(sender: UIButton) {
        let number = self.freecallButton.titleLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(number)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLocationSegue"
        {
            let theDestination: ServiceLocationViewController = segue.destinationViewController as! ServiceLocationViewController
            theDestination.currentActivity = self.currentActivity
        }
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
