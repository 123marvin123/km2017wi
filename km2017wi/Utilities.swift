//
//  Utilities.swift
//  km2017wi
//
//  Created by Marvin Haschker on 14.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit

func collectionViewShadow(cell: UICollectionViewCell) {
    cell.contentView.layer.cornerRadius = 10.0
    cell.contentView.layer.borderWidth = 1.0
    cell.contentView.layer.borderColor = UIColor.clear.cgColor
    cell.contentView.layer.masksToBounds = true
    
    cell.layer.shadowColor = UIColor.gray.cgColor
    cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    cell.layer.backgroundColor = UIColor.clear.cgColor
    cell.layer.shadowRadius = 3.0
    cell.layer.shadowOpacity = 0.75
    cell.layer.masksToBounds = false
    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
}
