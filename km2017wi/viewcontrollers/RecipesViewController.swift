//
//  RecipesViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import Kingfisher
import Cosmos

extension RecipesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = collectionView.visibleCells as! [OnlineRecipeCollectionViewCell]
        let bounds = collectionView.bounds
        for cell in cells {
            cell.updateParallaxOffset(collectionViewBounds: bounds)
        }
    }
}

extension RecipesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = self.collectionView(collectionView, numberOfItemsInSection: 0)
        if indexPath.item < itemCount - 3 {
            return
        }
        
        if isFiltering() && isFilteringOnline && self.currentRemoteSearchIndex < self.maxRemoteSearchIndex && !isSearchResult {
            downloadRemoteRecipes(forTerm: searchController.searchBar.text ?? "", page: self.currentRemoteSearchIndex + 1)
        } else if !isFiltering() && self.currentCategoryRecipeIndex < self.maxCategoryRecipeIndex {
            if !isSearchResult {
                loadRecipes(forPage: self.currentCategoryRecipeIndex + 1)
            } else {
                loadSearchResult(forPage: self.currentCategoryRecipeIndex + 1)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() && !isFilteringOnline {
            return filteredRecipes.count
        } else {
            if isFilteringOnline {
                return remoteRecipes.count
            } else {
                return recipes.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onlineRecipeCell", for: indexPath) as! OnlineRecipeCollectionViewCell
        let recipe = object(at: indexPath)
        
        UIView.transition(with: cell.image, duration: 0.25, options: .transitionCrossDissolve, animations: {
            cell.image.kf.setImage(with: recipe.image)
        }, completion: nil)
        
        cell.rating.rating = recipe.rating
        cell.title.text = recipe.title
        cell.rating.text = recipe.numberOfRatings
        
        collectionViewShadow(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRecipeDetailSegue", sender: object(at: indexPath))
    }
    
}

extension RecipesViewController : UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty() {
            isFilteringOnline = false
            remoteRecipes.removeAll()
            currentRemoteSearchIndex = 1
            maxRemoteSearchIndex = 1
            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        
        filterLocalRecipes(forTerm: searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFilteringOnline = false
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        filterLocalRecipes(forTerm: "")
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard category != nil else { return }
        
        if let term = searchBar.text {
            isFilteringOnline = true
            filterRemoteRecipes(forTerm: term)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

class RecipesViewController: UIViewController {

    var category: OnlineCategory? = nil
    
    var recipes: [OnlineRecipe] = []
    var filteredRecipes: [OnlineRecipe] = []
    var remoteRecipes: [OnlineRecipe] = []
    
    var currentCategoryRecipeIndex = 1
    var currentRemoteSearchIndex = 1
    
    var maxCategoryRecipeIndex = 1
    var maxRemoteSearchIndex = 1
    
    var isFilteringOnline: Bool = false
    var isSearchResult: Bool = false
    var searchCategories: [OnlineCategory] = []
    var searchResultTerm: String = ""
    
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Schlüsselwörter"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        self.navigationItem.title = category?.title ?? "Suchergebnis"
        
        activityIndicator.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        if !isSearchResult {
            loadRecipes(forPage: 1)
        }
    }
    
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func loadRecipes(forPage page: Int = 1) {
        showLoadingIndicator()
        Alamofire.request("https://www.rezeptwelt.de/kategorien/\(category?.id ?? "grundrezepte")?page=\(page)&rows=12").responseString { (response) in
            if response.error != nil {
                log.error("Could not get recipes.")
                return
            }
            
            if let str = response.result.value {
                self.parseLocalRecipes(str: str, page: page)
            }
        }
    }
    
    func parseLocalRecipes(str: String, page: Int) {
        Utilities.parseRecipeList(html: str, finished: { (parsedRecipes, maxIndex, error) in
            self.hideLoadingIndicator()
            guard error == nil else { return }
            
            self.currentCategoryRecipeIndex = page
            self.maxCategoryRecipeIndex = maxIndex ?? page
            if page == 1 {
                self.recipes = parsedRecipes
                self.collectionView.reloadData()
            } else {
                let lastIndex = self.recipes.endIndex
                self.recipes.append(contentsOf: parsedRecipes)
                
                var indiciesToBeUpdated: [IndexPath] = []
                for i in lastIndex..<self.recipes.endIndex {
                    indiciesToBeUpdated.append(IndexPath(item: i, section: 0))
                }
                
                self.collectionView.insertItems(at: indiciesToBeUpdated)
            }
        })
    }
    
    func loadSearchResult(forPage page: Int = 1, rows: Int = 12) {
        showLoadingIndicator()
        let encodedSearchTerm = searchResultTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let categoryTerm = searchCategories.compactMap { $0.id }.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    
        Alamofire.request("https://www.rezeptwelt.de/suche?&filters=categories%3A\(categoryTerm)%3B&search=\(encodedSearchTerm)&rows=\(rows)&page=\(page)").responseString { (response) in
            if response.error != nil {
                log.error("Could not get search result: \(response.error!.localizedDescription)")
                return
            }
            
            if let str = response.result.value {
                self.parseLocalRecipes(str: str, page: page)
            }
        }
    }
    
    private func filterLocalRecipes(forTerm searchTerm: String) {
        if isFilteringOnline {
            filteredRecipes = remoteRecipes.filter({ (recipe) -> Bool in
                return recipe.title.lowercased().contains(searchTerm.lowercased())
            })
        } else {
            filteredRecipes = recipes.filter({ (recipe) -> Bool in
                return recipe.title.lowercased().contains(searchTerm.lowercased())
            })
        }
        
        collectionView.reloadData()
    }
    
    func filterRemoteRecipes(forTerm searchTerm: String) {
        downloadRemoteRecipes(forTerm: searchTerm)
    }
    
    private func downloadRemoteRecipes(forTerm searchTerm: String, page: Int = 1) {
        showLoadingIndicator()
        Alamofire.request("https://www.rezeptwelt.de/suche?filters=categories%3A\(category?.id ?? "grundrezepte")%3B&search=\(searchTerm)&rows=12&page=\(page)").responseString { (response) in
            if response.error != nil {
                log.error("Could not search for recipes")
                return
            }
            
            if let str = response.result.value {
                
                Utilities.parseRecipeList(html: str, finished: { (parsedRecipes, maxIndex, error) in
                    self.hideLoadingIndicator()
                    guard error == nil else { return }
                    
                    
                    self.currentRemoteSearchIndex = page
                    self.maxRemoteSearchIndex = maxIndex ?? page
                    
                    if page == 1 {
                        self.remoteRecipes = parsedRecipes
                        self.collectionView.reloadData()
                    } else {
                        let lastIndex = self.remoteRecipes.endIndex
                        self.remoteRecipes.append(contentsOf: parsedRecipes)
                        
                        //TODO: helper method
                        var indiciesToBeUpdated: [IndexPath] = []
                        for i in lastIndex..<self.remoteRecipes.endIndex {
                            indiciesToBeUpdated.append(IndexPath(item: i, section: 0))
                        }
                        
                        self.collectionView.insertItems(at: indiciesToBeUpdated)
                    }
                })
            }
        }
    }
    
    private func object(at index: IndexPath) -> OnlineRecipe {
        if isFiltering() && !isFilteringOnline {
            return filteredRecipes[index.item]
        } else {
            if isFilteringOnline {
                return remoteRecipes[index.item]
            } else {
                return recipes[index.item]
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeDetailSegue" {
            if let recipe = sender as? OnlineRecipe {
                let viewController = segue.destination as! RecipeDetailViewController
                viewController.recipe = recipe
            }
        }
    }
    
    

}
