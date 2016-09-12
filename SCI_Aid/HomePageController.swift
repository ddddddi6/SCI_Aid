//
//  HomePageController.swift
//  SCI_Aid
//
//  Created by Dee on 15/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Foundation


class HomePageController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.view.backgroundColor = UIColor(red: 23/255.0, green: 123/255.0, blue: 156/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 55/255.0, green: 101/255.0, blue: 170/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
