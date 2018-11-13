//
//  OnlineCategory.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation
import UIKit

class OnlineCategory {
    
    var title: String
    var image: UIImage? = nil
    var id: String
    
    init(id: String, title: String, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.image = image
    }
    
}
