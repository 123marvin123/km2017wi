//
//  ParallaxCell.swift
//  km2017wi
//
//  Created by Marvin Haschker on 15.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit

class ParallaxCell : UICollectionViewCell {
    
    @IBOutlet weak var centerYLayoutConstraint: NSLayoutConstraint!
    
    var parallaxOffset: CGFloat = 0 {
        didSet {
            centerYLayoutConstraint.constant = parallaxOffset
        }
    }
    
    var parallaxFactor: CGFloat = 15
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + (self.bounds.height / 2)
        let scaleFactor = parallaxFactor / maxVerticalOffset
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
}
