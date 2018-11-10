//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

enum MessageFormat: Int {
    case Header0 = 0
    case Header1 = 1
    case MessageType = 2
    case CommandType = 3
    case Minute = 4
    case Second = 5
    case Speed = 6
    case Temperature = 7
    case WeightStatus = 8
    case WeightH = 9
    case WeightL = 10
    case MeasuredTemperature = 11
    case RecipeClass = 12
    case RecipeId = 13
    case RecipeStep = 14
    case MachineState = 15
    case LedStateH = 16
    case LedStateL = 17
    case Unused0 = 18
    case Unused1 = 19
    case CRC = 20
    case Count = 21
}