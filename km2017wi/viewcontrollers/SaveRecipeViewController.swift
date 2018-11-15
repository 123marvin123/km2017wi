//
//  SaveRecipeViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 15.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Eureka
import FloatLabelRow
import ImageRow
import Kingfisher

class SaveRecipeViewController: FormViewController {

    var recipe: OnlineRecipe!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Titel")
        
            <<< TextFloatLabelRow() { row in
                row.title = "Rezepttitel"
                row.value = recipe.title
            }
        
            <<< TextFloatLabelRow() { row in
                row.title = "Kurzbeschreibung"
            }
        
        form +++ ImageRow() { row in
            row.title = "Bild"
            row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
            row.clearAction = .yes(style: .destructive)
            KingfisherManager.shared.retrieveImage(with: recipe.image!, options: nil, progressBlock: nil,
                                                   completionHandler: { (image, _, _, _) in
                if let image = image { row.value = image }
            })
        }
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveRecipe(_ sender: Any) {
        //TODO: implement
        dismiss(sender)
    }
}
