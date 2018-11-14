//
//  RecipeDetailViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 13.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import Kingfisher
import Auk
import Eureka
import ViewRow

class RecipeDetailViewController: FormViewController  {

    var recipe: OnlineRecipe!
    private let titleScrollView = UIScrollView()
    private var ingredientsSection = Section("Zutaten")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = recipe.title
        parseDetailPage()
        
        form +++ ViewRow<UIScrollView>()
                .cellSetup({ (cell, row) in
                    cell.view = self.titleScrollView
                    
                    cell.contentView.addSubview(cell.view!)
                    
                    cell.viewRightMargin = 0
                    cell.viewLeftMargin = 0
                    cell.viewBottomMargin = 0
                    cell.viewTopMargin = 0
                    
                    cell.height = { return CGFloat(200) }
                })
        
        form +++ ingredientsSection
        form +++ Section("Zubereitung")
        
        titleScrollView.auk.settings.contentMode = .scaleAspectFill
        titleScrollView.auk.startAutoScroll(delaySeconds: 12)
        
    }
    

    private func parseDetailPage() {
        Alamofire.request(recipe.detailUrl).responseString { (response) in
            if let error = response.error {
                log.error("Error while downloading detail page.", context: error)
                return
            }
            
            if let htmlStr = response.result.value {
                do {
                    let doc = try SwiftSoup.parse(htmlStr)

                    for element in try doc.getElementsByClass("recipe-main-image") {
                        let src = try element.attr("src")
                        
                        KingfisherManager.shared.retrieveImage(with: URL(string: src)!, options: nil, progressBlock: nil, completionHandler: { (image,  _, _, _) in
                            if let image = image {
                               self.titleScrollView.auk.show(image: image)
                            }
                        })
                        
                    }
                    
                    for ingredient in try doc.getElementsByAttributeValue("itemprop", "recipeIngredient") {
                        let text = try ingredient.text()
                        let row = LabelRow() {
                            $0.title = text
                        }
                        self.ingredientsSection.append(row)
                    }
                    
                    if let yield = try doc.getElementsByAttributeValue("itemprop", "recipeYield").first() {
                        let str = try yield.text()
                        self.ingredientsSection.footer = HeaderFooterView(title: "Portionen: \(str)")
                        self.ingredientsSection.reload()
                    }
                    
                } catch let e {
                    log.error("Error while parsing detail page.", context: e)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
