//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

enum CommandType: UInt8 {
    case None = 0 //non-default
    case Pause = 1
    case Start = 2
    case Stop = 3
    case WeightStart = 4
    case WeightStop = 5
    case WeightTare = 6
    case WifiPowerOff = 7
    case UpdateValues = 8
}