//
//  OnlineRecipeCollectionViewCell.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Cosmos
import Hero

class OnlineRecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var id: String? {
        didSet {
            image.hero.id = id
        }
    }
    
}
