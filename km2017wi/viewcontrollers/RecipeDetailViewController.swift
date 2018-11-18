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
import RichTextRow
import SwiftMessages

class RecipeDetailViewController: FormViewController  {

    var recipe: OnlineRecipe!
    private let titleScrollView = UIScrollView()
    private var ingredientsSection = Section("Zutaten")
    private var preparationSection = Section("Zubereitung")
    
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
        form +++ preparationSection
        
        
        titleScrollView.auk.settings.contentMode = .scaleAspectFill
        titleScrollView.auk.startAutoScroll(delaySeconds: 12)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
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
                    
                    if let stepContainer = try doc.getElementById("ingredient-section")?.child(0) {
                        
                        for child in stepContainer.children().filter({ return $0.tagName().elementsEqual("ul") }) {
                            
                            if child.siblingIndex > 0 {
                                let upperElement = try child.previousElementSibling()
                                if upperElement?.tagName() == "p" {
                                    let text = try upperElement?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                    if text.count > 0 {
                                        let row = LabelRow() {
                                            $0.title = text
                                            $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                                        }
                                        self.ingredientsSection.append(row)
                                    }
                                }
                            }
                           
                            for ingredient in try child.getElementsByAttributeValue("itemprop", "recipeIngredient") {
                                let text = try ingredient.text().trimmingCharacters(in: .whitespacesAndNewlines)
                                if text.count == 0 { continue }
                                
                                let row = LabelRow() {
                                    $0.title = text
                                    $0.cell.textLabel?.numberOfLines = 0
                                }
                                self.ingredientsSection.append(row)
                            }
                            
                        }
                        self.ingredientsSection.reload()
                    
                        
                    }
                    
                    if let yield = try doc.getElementsByAttributeValue("itemprop", "recipeYield").first() {
                        let str = try yield.text()
                        self.ingredientsSection.footer = HeaderFooterView(title: "Portionen: \(str)")
                        self.ingredientsSection.reload()
                    }
                    
                    if let preparation = try doc.getElementsByClass("steps-list").first()?.children() {
                        let prepHtml = try preparation.html();
                        let textView = RichTextRow() {
                            $0.title = "Zubereitung"
                            $0.value = prepHtml
                        }
        
                        self.preparationSection.append(textView)
                    }
                    
                    if let tips = try doc.getElementsByClass("tips").first()?.getElementsByTag("p").compactMap({ return try $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }).joined(separator: "\n") {
                        
                        if tips.count > 0 {
                            let section = Section("Tipps")
                            let label = LabelRow() {
                                $0.title = tips
                                $0.cell.textLabel?.numberOfLines = 0
                            }
                            section.append(label)
                            
                            self.form.append(section)
                        }
                    }
                    
                } catch let e {
                    log.error("Error while parsing detail page.", context: e)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "saveRecipeSegue" {
            if let saveController = (segue.destination as? UINavigationController)?.children.first as? SaveRecipeViewController {
                saveController.recipe = self.recipe
            } else {
                log.error("Destination was not SaveRecipeViewController")
            }
        }
    }
    
}
