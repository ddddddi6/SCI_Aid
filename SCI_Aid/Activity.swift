//
//  Activity.swift
//  SCI_Aid
//
//  Created by Dee on 18/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class Activity: NSObject {
    
    var name: String?
    var address: String?
    var desc: String?
    var website: String?
    var phone: String?
    var freecall: String?
    var email: String?
    
    override init()
    {
        self.name = "Unknown"
        self.address = "Unknown"
        self.desc = "Unknown"
        self.website = "Unknown"
        self.phone = "Unknown"
        self.freecall = "Unknown"
        self.email = "Unknown"
        // Default intialization of each variables
    }
    
    init(name: String, address: String, desc: String, website: String, phone: String, freecall: String, email: String)
    {
        self.name = name
        self.address = address
        self.desc = desc
        self.website = website
        self.phone = phone
        self.freecall = freecall
        self.email = email

        // Custome initialization of each variables
    }
}
