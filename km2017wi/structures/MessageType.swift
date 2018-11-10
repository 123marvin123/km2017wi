//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

enum MessageType: UInt8 {
    case None = 0
    case Control = 1
    case Report = 2
    case Query = 3
    case KeepAlive = 4
}