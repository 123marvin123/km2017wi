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

extension RecipesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = self.collectionView(collectionView, numberOfItemsInSection: 0)
        if indexPath.item < itemCount - 3 {
            return
        }
        
        if isFiltering() && isFilteringOnline && self.currentRemoteSearchIndex < self.maxRemoteSearchIndex {
            downloadRemoteRecipes(forTerm: searchController.searchBar.text ?? "", page: self.currentRemoteSearchIndex + 1)
        } else if !isFiltering() && self.currentCategoryRecipeIndex < self.maxCategoryRecipeIndex {
            loadRecipes(forPage: self.currentCategoryRecipeIndex + 1)
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
        cell.ratingLabel.text = recipe.numberOfRatings
        
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
        
        self.navigationItem.title = category?.title
        
        activityIndicator.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        loadRecipes(forPage: 1)
    }
    
    @objc
    func scrollToTop(_ sender: Any) {
        
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
                
                self.parseHtml(htmlStr: str, finished: { (parsedRecipes, maxIndex, error) in
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
        Alamofire.request("https://www.rezeptwelt.de/suche?filters=categories%3A\(category?.id ?? "grundrezepte")%3B&search=\(searchTerm)&page=\(page)").responseString { (response) in
            if response.error != nil {
                log.error("Could not search for recipes")
                return
            }
            
            if let str = response.result.value {
                
                self.parseHtml(htmlStr: str, finished: { (parsedRecipes, maxIndex, error) in
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
    
    private func parseHtml(htmlStr: String, finished: @escaping ([OnlineRecipe], Int?, Error?) -> Void) {
        DispatchQueue.global().async {
            var collection: [OnlineRecipe] = []
            var maxIndex: Int? = nil
            
            do {
                let doc = try SwiftSoup.parse(htmlStr)
                let galleryView = try doc.getElementById("recipe-gallery-view")
                if let columns = try galleryView?.getElementsByClass("col-sm-4") {
                    for column in columns {
                        if let recipe = self.parseRecipeColumn(column: column) {
                            collection.append(recipe)
                        }
                    }
                }
                
                if let pager = try doc.getElementsByClass("pager").first() {
                    if let lastLinkElement = try pager.getElementsByClass("last-link").first() {
                        let maxPageString = try lastLinkElement.attr("href")
                        if let endIndex = maxPageString.range(of: "page=")?.upperBound {
                            maxIndex = Int(maxPageString[endIndex...])
                        }
                    }
                }
                
            } catch let e {
                log.error("Error while parsing html.", context: e)
                finished(collection, nil, e)
                return
            }
            
            DispatchQueue.main.sync {
                finished(collection, maxIndex, nil)
            }
        }
    }
    
    private func parseRecipeColumn(column: Element) -> OnlineRecipe? {
        do {
            let title = try column.getElementsByClass("item-title").first()?.text() ?? "-"
            let imageUrl = try column.getElementsByClass("img-responsive").first()?.attr("src")
            let ratingStr = try column.getElementsByAttributeValue("itemProp", "ratingValue").first()?.attr("content") ?? "0"
            let rating = Double(ratingStr) ?? 0
            
            let numberOfRatings = try column.getElementsByClass("rate-amount").first()?.text() ?? "(0 Bewertungen)"
            
            let url = URL(string: imageUrl!)
            return OnlineRecipe(title: title, rating: rating, numberOfRatings: numberOfRatings, image: url)
        } catch let e {
            log.error("Error while parsing recipe :(", context: e)
        }
        return nil
    }

}
