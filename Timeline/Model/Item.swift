//
//  Item.swift
//  Timeline
//
//  Created by Erik Salas on 3/25/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated : Date?
    @objc dynamic var order = 0 //Trying to dynamically update the current indexpath ?????????
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
