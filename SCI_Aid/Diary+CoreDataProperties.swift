//
//  Diary+CoreDataProperties.swift
//  SCI_Aid
//
//  Created by Dee on 11/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Diary {

    @NSManaged var condition: NSNumber?
    @NSManaged var diaryDate: NSDate?
    @NSManaged var hasCatheter: NSNumber?
    @NSManaged var hasToilet: NSNumber?
    @NSManaged var isBlocked: NSNumber?
    @NSManaged var isDysreflexia: NSNumber?
    @NSManaged var isLittle: NSNumber?
    @NSManaged var isMuch: NSNumber?
    @NSManaged var isPainful: NSNumber?
    @NSManaged var isSmelly: NSNumber?
    @NSManaged var status: String?

}
