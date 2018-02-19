//
//  NoteClass+CoreDataProperties.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 20/02/18.
//  Copyright © 2018 Raghavendra Shedole. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteClass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteClass> {
        return NSFetchRequest<NoteClass>(entityName: "Note")
    }

    @NSManaged public var note_title: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var priority: Int16

}

