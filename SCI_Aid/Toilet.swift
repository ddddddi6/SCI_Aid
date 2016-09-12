//
//  Toilet.swift
//  SCI_Aid
//
//  Created by Dee on 31/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class Toilet: NSObject {
    var name: String?
    var latitude: Double?
    var longitude: Double?
    
    override init()
    {
        self.name = "Unknown"
        self.latitude = 0
        self.longitude = 0
        // Default intialization of each variables
    }
    
    init(name: String, latitude: Double, longitude: Double)
    {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        
        // Custome initialization of each variables
    }

}
