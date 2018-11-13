//
//  Recipe.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation

class Recipe {
    
    var category: Category
    var index: Int
    private(set) var ingredients: [String] = []
    var name: String
    private(set) var steps: [RecipeStep] = []
    var uuid: String
    
    init(index: Int, name: String, category: Category, uuid: String = "") {
        self.index = index
        self.name = name
        self.category = category
        self.uuid = uuid
    }
    
    func addIngredient(index: Int, ingredient: String) {
        ingredients.insert(ingredient, at: index)
    }
    
    func addIngredient(ingredient: String) {
        ingredients.append(ingredient)
    }
    
    func addIngredients(ingredients: [String]) {
        self.ingredients.append(contentsOf: ingredients)
    }
    
    func addRecipeStep(index: Int, step: RecipeStep) {
        steps.insert(step, at: index)
    }
    
    func addRecipeStep(step: RecipeStep) {
        steps.append(step)
    }
    
    func addRecipeSteps(steps: [RecipeStep]) {
        self.steps.append(contentsOf: steps)
    }
    
}
