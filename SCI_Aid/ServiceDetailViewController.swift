//
//  ServiceDetailViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ServiceDetailViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
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
        addressLabel.text = currentActivity.address
        descLabel.text = currentActivity.desc
        phoneLabel.text = currentActivity.phone
        websiteLabel.text = currentActivity.website
        emailLabel.text = currentActivity.email
        freecallLabel.text = currentActivity.freecall
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ServiceDetailViewController.navigatePlace(_:)))
        if addressLabel.text != "N.A." {
            addressLabel.userInteractionEnabled=true
            addressLabel.addGestureRecognizer(tapGesture)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigatePlace(sender:UITapGestureRecognizer) {
        self.performSegueWithIdentifier("showLocationSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLocationSegue"
        {
            let theDestination : ServiceLocationViewController = segue.destinationViewController as! ServiceLocationViewController
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
