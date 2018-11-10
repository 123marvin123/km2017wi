//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

enum MachineState: UInt8 {
    case Idle = 0
    case Running = 1
    case Paused = 2
    case ErrorNtcShortCircuit = 3
    case ErrorNtcOpenCircuit = 4
    case ErrorSafetySwitchOpenCircuit = 5
    case ErrorHallElementMotorFailure = 6
    case ErrorPotTakeOff = 7
}
