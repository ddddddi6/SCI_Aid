//
//  Stop.swift
//  SCI_Aid
//
//  Created by Dee on 17/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class Stop: NSObject {
    
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var id: Int?
    var routeType: Int?
    
    override init()
    {
        self.latitude = 0
        self.longitude = 0
        self.name = "Unknown"
        self.id = -1
        self.routeType = -1
        // Default intialization of each variables
    }
    
    init(latitude: Double, longitude: Double, name: String, id: Int, routeType: Int)
    {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.id = id
        self.routeType = routeType
        // Custome initialization of each variables
    }
}
