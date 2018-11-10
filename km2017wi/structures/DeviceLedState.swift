//
//  DeviceLedState.swift
//  km2017wi
//
//  Created by Marvin Haschker on 10.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation

/** Bitmask **/
enum DeviceLedState: Int {
    case Jam = 1
    case Steaming = 2
    case Soup = 4
    case Kneading = 8
    case Weight = 16
    case Wifi = 32
    case Reverse = 64
    case Turbo = 128
    case StartStopOn = 256
    case StartStopFlashing = 512
}
