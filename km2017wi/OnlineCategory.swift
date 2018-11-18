//
//  OnlineCategory.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation
import UIKit

class OnlineCategory : Hashable, CustomStringConvertible {
    
    static func == (lhs: OnlineCategory, rhs: OnlineCategory) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.image == rhs.image
    }
    
    public var hashValue: Int {
        get {
            return title.hashValue & id.hashValue & image.hashValue
        }
    }
    
    var description: String { return title }
    
    var title: String
    var image: UIImage? = nil
    var id: String
    
    init(id: String, title: String, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.image = image
    }
    
}
