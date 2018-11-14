//
//  CookRecipeViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit

class CookRecipeViewController : UIViewController {

    var recipe: Recipe? = nil
    private(set) var step: Int = 0
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log.info("Got recipe: \(String(describing: recipe))")
        self.navigationItem.title = "Kochen: \(recipe?.name ?? "Fehler")"
        cook()
    }
    
    private func cook() {
        step = -1
        nextStep()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if step + 1 < recipe?.steps.count ?? 256 {
            nextStep()
        } else {
            resetMachine()
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func resetMachine() {
        machine.updateWithoutTrigger {
            machine.recipeStep = 0
            machine.recipeId = 0
            machine.recipeClass = .Reset
        }
        if !machine.commit() {
            log.error("Error while resetting machine.")
        }
    }
    
    private func nextStep() {
        step = step + 1
        machine.updateWithoutTrigger {
            machine.recipeClass = recipe?.category.getMenuCategory()! ?? .CustomRecipe
            machine.recipeId = UInt8(recipe?.index ?? 0)
            machine.recipeStep = UInt8(step + 1)
            
            if let recipeStep = self.recipe?.steps[step] {
                let time = recipeStep.duration
                machine.minutes = UInt8(time.minutes)
                machine.seconds = UInt8(time.seconds)
                machine.speed = UInt8(recipeStep.speed)
                machine.temperature = UInt8(recipeStep.temperature)
                
                stepLabel.text = "Schritt #\(step + 1)"
                tempLabel.text = "Temperatur: \(recipeStep.temperature)"
                speedLabel.text = "Geschwindigkeit: \(recipeStep.speed)"
                timeLabel.text = "Zeit: \(time.minutes) Minuten, \(time.seconds) Sekunden"
                descriptionLabel.text = "Beschreibung:\n\(recipeStep.description)"
            }
            
        }
        if !machine.commit() {
            log.error("Error while starting recipe.")
        }
    }
    
}

