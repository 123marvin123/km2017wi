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
                      OnlineCategory(id: "hauptgerichte-mit-fisch-meeresfruchten", title: "Hauptgerichte mit Fisch", image: UIImage(named: "05-Hauptgericht-Fisch")),
                      OnlineCategory(id: "hauptgerichte-mit-gemuse", title: "Hauptgerichte mit Gemüse", image: UIImage(named: "06-Hauptgericht-Gemüse")),
                      OnlineCategory(id: "sonstige-hauptgerichte", title: "Sonstige Hauptgerichte", image: UIImage(named: "07-Sonstige-Hauptgerichte")),
                      OnlineCategory(id: "beilagen", title: "Beilagen", image: UIImage(named: "08-Beilagen")),
                      OnlineCategory(id: "saucendipsbrotaufstriche", title: "Saucen/Dips/Brotaufstriche", image: UIImage(named: "09-Dips")),
                      OnlineCategory(id: "desserts", title: "Desserts", image: UIImage(named: "10-Desserts")),
                      OnlineCategory(id: "backen-suß", title: "Backen süß", image: UIImage(named: "11-BackenSüß")),
                      OnlineCategory(id: "backen-herzhaft", title: "Backen herzhaft", image: UIImage(named: "12-BackenHerzhaft")),
                      OnlineCategory(id: "brot-brotchen", title: "Brot & Brötchen", image: UIImage(named: "13-Brot")),
                      OnlineCategory(id: "getranke", title: "Getränke", image: UIImage(named: "14-Getränke")),
                      OnlineCategory(id: "babybeikostbreie", title: "Baby-Beikost/Breie", image: UIImage(named: "15-Brei"))]
    
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
        
        collectionViewShadow(cell: cell)
        
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
