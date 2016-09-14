//
//  ServiceDetailViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ServiceDetailViewController: UIViewController {

    @IBOutlet var descButton: UIButton!
    @IBOutlet var addressButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var freecallLabel: UILabel!
    
    var currentActivity: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Disability Service"
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        nameLabel.text = currentActivity.name
        nameLabel.layer.cornerRadius = 5
        nameLabel.layer.masksToBounds = true
        addressButton.setTitle(currentActivity.address, forState: .Normal)
        addressButton.contentHorizontalAlignment = .Left
        descButton.setTitle(currentActivity.desc, forState: .Normal)
        addressButton.contentHorizontalAlignment = .Left
        phoneLabel.text = currentActivity.phone
        websiteLabel.text = currentActivity.website
        emailLabel.text = currentActivity.email
        freecallLabel.text = currentActivity.freecall
        
        if addressButton.titleLabel!.text == "N.A." {
            addressButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func navigateService(sender: UIButton) {
        self.performSegueWithIdentifier("showLocationSegue", sender: self)
    }
    
    @IBAction func displayDescription(sender: UIButton) {
        self.performSegueWithIdentifier("showDescription", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLocationSegue"
        {
            let theDestination: ServiceLocationViewController = segue.destinationViewController as! ServiceLocationViewController
            theDestination.currentActivity = self.currentActivity
        } else if segue.identifier == "showDescription" {
            let theDestination: ServiceDescViewController = (segue.destinationViewController as! UINavigationController).topViewController as! ServiceDescViewController
            theDestination.name = currentActivity.name
            theDestination.desc = currentActivity.desc
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
