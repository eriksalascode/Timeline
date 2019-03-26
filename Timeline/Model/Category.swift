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
    let items = List<Item>()
}
