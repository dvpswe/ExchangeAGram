//
//  FeedItem+CoreDataProperties.swift
//  ExchangeAGram
//
//  Created by Darryl Pendergrass on Nov/8/15.
//  Copyright © 2015 Phoenix Media Services, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedItem {

    @NSManaged var caption: String?
    @NSManaged var image: NSData?
    @NSManaged var thumbNail: NSData?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var uniqueID: String?
    @NSManaged var filtered: NSNumber?

}
