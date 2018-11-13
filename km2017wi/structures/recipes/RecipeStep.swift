//
//  RecipeStep.swift
//  km2017wi
//
//  Created by Marvin Haschker on 11.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation

class RecipeStep {
    
    private(set) var duration: (minutes: Int, seconds: Int)
    private(set) var speed: Int
    private(set) var temperature: Int
    private(set) var description: String
    
    init(duration: Int, speed: Int, temperature: Int, description: String) {
        self.duration = RecipeStep.convertSeconds(seconds: duration)
        self.speed = speed
        self.temperature = temperature
        self.description = description
    }
    
    private static func convertSeconds(seconds: Int) -> (minutes: Int, seconds: Int) {
        return (seconds / 60, seconds % 60)
    }

}
