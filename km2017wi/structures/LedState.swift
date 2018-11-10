//
//  LedState.swift
//  km2017wi
//
//  Created by Marvin Haschker on 10.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import Foundation

class LedState {
    private var bits: Int = 0
    
    var kneading: Bool {
        get { return checkBit(bitmask: .Kneading) }
    }
    
    var steaming: Bool {
        get { return checkBit(bitmask: .Steaming) }
    }

    var soup: Bool {
        get { return checkBit(bitmask: .Soup) }
    }
    
    var jam: Bool {
        get { return checkBit(bitmask: .Jam) }
    }
    
    var weight: Bool {
        get { return checkBit(bitmask: .Weight) }
    }
    
    var wifi: Bool {
        get { return checkBit(bitmask: .Wifi) }
    }
    
    var reverse: Bool {
        get { return checkBit(bitmask: .Reverse) }
    }
    
    var turbo: Bool {
        get { return checkBit(bitmask: .Turbo) }
    }
    
    var startStopOn: Bool {
        get { return checkBit(bitmask: .StartStopOn) }
    }
    
    var startStopFlashing: Bool {
        get { return checkBit(bitmask: .StartStopFlashing) }
    }
    
    init (byte0: UInt8, byte1: UInt8) {
        bits = (Int(byte0) << 8) + Int(byte1)
    }
    
    private func checkBit(bitmask: DeviceLedState) -> Bool {
        return (self.bits & bitmask.rawValue) != 0
    }
}
