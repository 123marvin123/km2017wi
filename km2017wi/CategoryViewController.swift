//
//  CategoryViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let categories = [OnlineCategory(id: "grundrezepte", title: "Grundrezepte", image: UIImage(named: "01-Grundrezepte")),
                      OnlineCategory(id: "vorspeisensalate", title: "Vorspeisen/Salate", image: UIImage(named: "02-Vorspeisen-Salate")),
                      OnlineCategory(id: "suppen", title: "Suppen", image: UIImage(named: "03-Suppen")),
                      OnlineCategory(id: "hauptgerichte-mit-fleisch", title: "Hauptgerichte mit Fleisch", image: UIImage(named: "04-Hauptgericht-Fleisch")),
                      OnlineCategory(id: "hauptgerichte-mit-fisch-meeresfruchten", title: "Hauptgerichte mit Fisch", image: UIImage(named: "05-Hauptgericht-Fisch"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryViewCell
        
        let category = categories[indexPath.row]
        
        cell.title.text = category.title
        cell.image.image = category.image
        cell.category = category
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? CategoryViewCell
        performSegue(withIdentifier: "showCategorySegue", sender: selectedCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategorySegue" {
            let recipesController = segue.destination as! RecipesViewController
            recipesController.category = (sender as? CategoryViewCell)?.category
        }
    }
    
}
