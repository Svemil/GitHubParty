//
//  Party+CoreDataProperties.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 10/01/2021.
//
//

import Foundation
import CoreData


extension Party {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Party> {
        return NSFetchRequest<Party>(entityName: "Party")
    }

    @NSManaged public var partyId: String?
    @NSManaged public var partyName: String?
    @NSManaged public var partyDateTime: String?
    @NSManaged public var partyDescription: String?
    @NSManaged public var partyMembersIds: Data?

}

extension Party : Identifiable {

}
