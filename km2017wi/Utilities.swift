//
//  Utilities.swift
//  km2017wi
//
//  Created by Marvin Haschker on 14.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import SwiftSoup

class Utilities {
    public static let categories = [OnlineCategory(id: "grundrezepte", title: "Grundrezepte", image: UIImage(named: "01-Grundrezepte")),
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
    
    public static func parseRecipeList(html: String, finished: @escaping ([OnlineRecipe], Int?, Error?) -> Void) {
        DispatchQueue.global().async {
            var collection: [OnlineRecipe] = []
            var maxIndex: Int? = nil
            
            do {
                let doc = try SwiftSoup.parse(html)
                let galleryView = try doc.getElementById("recipe-gallery-view")
                if let columns = try galleryView?.getElementsByClass("col-sm-4") {
                    for column in columns {
                        if let recipe = parseRecipeColumn(column: column) {
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
    
    private static func parseRecipeColumn(column: Element) -> OnlineRecipe? {
        do {
            let title = try column.getElementsByClass("item-title").first()?.text() ?? "-"
            let imageUrl = try column.getElementsByClass("img-responsive").first()?.attr("src")
            let ratingStr = try column.getElementsByAttributeValue("itemProp", "ratingValue").first()?.attr("content") ?? "0"
            let href = try column.getElementsByClass("item-link").first()?.attr("href")
            let rating = Double(ratingStr) ?? 0
            
            let numberOfRatings = try column.getElementsByClass("rate-amount").first()?.text() ?? "(0 Bewertungen)"
            
            let url = URL(string: imageUrl!)
            let hrefUrl = URL(string: "https://www.rezeptwelt.de\(href!)")
            return OnlineRecipe(title: title, rating: rating, numberOfRatings: numberOfRatings, detail: hrefUrl!, image: url)
        } catch let e {
            log.error("Error while parsing recipe :(", context: e)
        }
        return nil
    }
    
    public static func loadRecipeDetails(html: String) {
        
    }
}

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

