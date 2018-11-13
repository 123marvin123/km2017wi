//
//  Category.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation

class Category {
    
    var index: Int
    var name: String
    
    init(index: Int, name: String) {
        self.index = index
        self.name = name
    }
    
    func getMenuCategory() -> RecipeClass? {
        return RecipeClass(rawValue: UInt8(index))
    }
    
}
