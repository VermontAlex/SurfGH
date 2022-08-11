//
//  CDRepos+CoreDataProperties.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//
//

import Foundation
import CoreData


extension CDRepos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRepos> {
        return NSFetchRequest<CDRepos>(entityName: "CDRepos")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var name: String?
    @NSManaged public var ownerName: String?
    @NSManaged public var repoDescription: String?
    @NSManaged public var stars: Int64
    @NSManaged public var isSelected: Bool

}

extension CDRepos : Identifiable {

}
