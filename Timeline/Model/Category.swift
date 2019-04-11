//
//  Category.swift
//  Timeline
//
//  Created by Erik Salas on 3/25/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var order : Int = 0

    let items = List<Item>()
}
