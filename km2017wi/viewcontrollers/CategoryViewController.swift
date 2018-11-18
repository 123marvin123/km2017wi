//
//  CategoryViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit

extension CategoryViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = collectionView.visibleCells as! [CategoryViewCell]
        let bounds = collectionView.bounds
        for cell in cells {
            cell.updateParallaxOffset(collectionViewBounds: bounds)
        }
    }
    
}

class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Utilities.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryViewCell
        
        let category = Utilities.categories[indexPath.row]
        
        cell.title.text = category.title
        cell.image.image = category.image
        cell.category = category
        cell.updateParallaxOffset(collectionViewBounds: collectionView.bounds)
        
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
