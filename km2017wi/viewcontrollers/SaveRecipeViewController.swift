//
//  SaveRecipeViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 15.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Eureka

class SaveRecipeViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Titel")
        
            <<< LabelRow() { row in
                    row.title = "Hallo"
            }
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveRecipe(_ sender: Any) {
        
    }
}
