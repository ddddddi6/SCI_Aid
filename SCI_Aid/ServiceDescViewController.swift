//
//  ServiceDescViewController.swift
//  SCI_Aid
//
//  Created by Dee on 14/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ServiceDescViewController: UIViewController {

    @IBOutlet var descLabel: UILabel!
    
    var desc: String!
    var name: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.descLabel.text = desc
        self.title = name
        // Do any additional setup after loading the view.
    }

    @IBAction func backToServiceDetail(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
