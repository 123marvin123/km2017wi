//
//  OnlineRecipe.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Kingfisher

class OnlineRecipe {
    
    var title: String
    var rating: Double
    var image: URL? = nil
    var numberOfRatings: String = "(1 Bewertung)"
    
    var detailUrl: URL
    
    init(title: String, rating: Double, numberOfRatings: String = "(1 Bewertung)", detail: URL, image: URL? = nil) {
        self.title = title
        self.rating = rating
        self.numberOfRatings = numberOfRatings
        self.image = image
        self.detailUrl = detail
    }

    
}
