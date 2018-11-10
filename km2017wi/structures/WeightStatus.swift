//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

enum WeightStatus: UInt8 {
    case Idle = 0
    case Running = 1
    case Overflow = 3
    case Calibrating = 5
}
