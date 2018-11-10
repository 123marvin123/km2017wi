//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation

class Message {

    static let DefaultHeader0: UInt8 = 0xff
    static let DefaultHeader1: UInt8 = 0x5a

    private var buffer = Data(capacity: 21)

    var header0 = DefaultHeader0
    var header1 = DefaultHeader1

    var messageType = MessageType.None
    var commandType = CommandType.None

    var minutes: UInt8 = 0
    var seconds: UInt8 = 0
    var speed: UInt8 = 0
    var temperature: UInt8 = 0
    private(set) var weightStatus = WeightStatus.Idle
    
    var weight: Int {
        get {
            return (Int(weightH) << 8) + Int(weightL) - 15000
        }
    }
    
    private var weightH: UInt8 = 0
    private var weightL: UInt8 = 0
    private(set) var measuredTemperature: UInt8 = 0
    
    var recipeClass: RecipeClass = RecipeClass.Reset
    var recipeId: UInt8 = 0
    var recipeStep: UInt8 = 0
    private(set) var machineState = MachineState.Idle

    private(set) var ledStateH: UInt8 = 0
    private(set) var ledStateL: UInt8 = 0
    private(set) var ledState: LedState? = nil
    
    var unused0: UInt8 = 0
    var unused1: UInt8 = 0
    var crc: UInt8 {
        get {
            var val: UInt8 = 0
            for i in 0..<MessageFormat.CRC.rawValue {
                val = val ^ buffer[i]
            }
            return val
        }
    }

    convenience init(fromData data: Data) {
        self.init()

        self.buffer = data
        mapValues(data: data)
        
        if !validateHeaders(header0: data[MessageFormat.Header0.rawValue], header1: data[MessageFormat.Header1.rawValue]) {
            log.warning("Headers of received message are not valid", context: self)
        }
        
        if !equalsCrc(crc: data[MessageFormat.CRC.rawValue]) {
            log.warning("CRC values of received data do not match.", context: self)
        }
    }
    
    convenience init(messageType: MessageType) {
        self.init()
        
        self.messageType = messageType
    }

    init() {}

    private func mapValues(data: Data) {
        header0 = data[MessageFormat.Header0.rawValue]
        header1 = data[MessageFormat.Header1.rawValue]

        self.messageType = MessageType(rawValue: data[MessageFormat.MessageType.rawValue]) ?? .None
        self.commandType = CommandType(rawValue: data[MessageFormat.CommandType.rawValue]) ?? .None

        self.minutes = data[MessageFormat.Minute.rawValue]
        self.seconds = data[MessageFormat.Second.rawValue]
        self.speed = data[MessageFormat.Speed.rawValue]
        self.temperature = data[MessageFormat.Temperature.rawValue]
        self.weightStatus = WeightStatus(rawValue: data[MessageFormat.WeightStatus.rawValue]) ?? .Idle
        self.weightH = data[MessageFormat.WeightH.rawValue]
        self.weightL = data[MessageFormat.WeightL.rawValue]
        self.measuredTemperature = data[MessageFormat.MeasuredTemperature.rawValue]
        self.recipeClass = RecipeClass(rawValue: data[MessageFormat.RecipeClass.rawValue]) ?? .Reset
        self.recipeId = data[MessageFormat.RecipeId.rawValue]
        self.recipeStep = data[MessageFormat.RecipeStep.rawValue]
        self.machineState = MachineState(rawValue: data[MessageFormat.MachineState.rawValue]) ?? .Idle
        
        self.ledStateH = data[MessageFormat.LedStateH.rawValue]
        self.ledStateL = data[MessageFormat.LedStateL.rawValue]
        self.ledState = LedState(byte0: ledStateH, byte1: ledStateL)
        self.unused0 = data[MessageFormat.Unused0.rawValue]
        self.unused1 = data[MessageFormat.Unused1.rawValue]
    }
    
    private func equalsCrc(crc: UInt8) -> Bool {
        return crc == self.crc
    }

    private func validateHeaders(header0: UInt8, header1: UInt8) -> Bool {
        return header0 == Message.DefaultHeader0 && header1 == Message.DefaultHeader1
    }
    
    func toData() -> Data {
        buffer[MessageFormat.Header0.rawValue] = self.header0
        buffer[MessageFormat.Header1.rawValue] = self.header1
        
        buffer[MessageFormat.MessageType.rawValue] = self.messageType.rawValue
        buffer[MessageFormat.CommandType.rawValue] = self.commandType.rawValue
        
        buffer[MessageFormat.Minute.rawValue] = self.minutes
        buffer[MessageFormat.Second.rawValue] = self.seconds
        buffer[MessageFormat.Speed.rawValue] = self.speed
        buffer[MessageFormat.Temperature.rawValue] = self.temperature
        
        buffer[MessageFormat.WeightStatus.rawValue] = self.weightStatus.rawValue
        buffer[MessageFormat.WeightH.rawValue] = self.weightH
        buffer[MessageFormat.WeightL.rawValue] = self.weightL
        buffer[MessageFormat.MeasuredTemperature.rawValue] = self.measuredTemperature
        buffer[MessageFormat.RecipeId.rawValue] = self.recipeId
        buffer[MessageFormat.RecipeClass.rawValue] = self.recipeClass.rawValue
        buffer[MessageFormat.RecipeStep.rawValue] = self.recipeStep
        buffer[MessageFormat.MachineState.rawValue] = self.machineState.rawValue
        
        buffer[MessageFormat.LedStateH.rawValue] = self.ledStateH
        buffer[MessageFormat.LedStateL.rawValue] = self.ledStateL
        buffer[MessageFormat.Unused0.rawValue] = self.unused0
        buffer[MessageFormat.Unused1.rawValue] = self.unused1
        buffer[MessageFormat.CRC.rawValue] = self.crc
        
        return buffer
    }

}
