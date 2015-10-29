//
//  FeedItem+CoreDataProperties.swift
//  ExhangeAGram
//
//  Created by Darryl Pendergrass on Oct/13/15.
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

}
