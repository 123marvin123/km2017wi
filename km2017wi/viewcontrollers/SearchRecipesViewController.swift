//
//  SearchRecipesViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 17.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import Eureka
import FloatLabelRow

class SearchRecipesViewController: FormViewController {

    var selectorRow: MultipleSelectorRow<OnlineCategory>!
    var searchTermRow: TextFloatLabelRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectorRow = MultipleSelectorRow<OnlineCategory>() { row in
            row.title = "Kategorien"
            row.selectorTitle = "Suchkategorien wählen"
            row.options = Utilities.categories
            row.value = Set(Utilities.categories)
        }
        
        searchTermRow = TextFloatLabelRow() { row in
            row.title = "Suchbegriff"
        }
        
        form +++ Section("Suchoptionen")
            <<< searchTermRow
            <<< selectorRow
        
        searchTermRow.cell.textField?.becomeFirstResponder()
    }
    
    @IBAction func search(_ sender: Any) {
        self.performSegue(withIdentifier: "showSearchResultSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchResultSegue" {
            let viewController = segue.destination as! RecipesViewController
            viewController.isSearchResult = true
            viewController.searchCategories = Array(selectorRow.value!)
            viewController.searchResultTerm = searchTermRow.value!
            viewController.loadSearchResult()
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
