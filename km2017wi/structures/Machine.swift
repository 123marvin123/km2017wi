//
// Created by Marvin Haschker on 10.11.18.
// Copyright (c) 2018 Marvin Haschker. All rights reserved.
//

import Foundation
import Socket
import SwiftyBeaver

class Machine {

    var connectionState: ConnectionState {
        get {
            guard let socket = socket else {
                return .Disconnected
            }
            
            if socket.isConnected {
                return .Connected
            } else {
                return .Disconnected
            }
        }
    }

    var socket: Socket? = nil
    private var keepAliveTimer: Timer? = nil
    private var doUpdate: Bool = true
    
    var minutes: UInt8 = 0 {
        didSet { propertyChanged(propName: "minutes") }
    }
    
    var seconds: UInt8 = 0 {
        didSet { propertyChanged(propName: "seconds") }
    }
    
    var speed: UInt8 = 0 {
        didSet { propertyChanged(propName: "speed") }
    }
    
    var temperature: UInt8 = 0 {
        didSet { propertyChanged(propName: "temperature") }
    }
    
    private(set) var measuredTemperature: UInt8 = 0
    private(set) var weight: Int = 0
    private(set) var weightStatus = WeightStatus.Idle
    
    var recipeClass = RecipeClass.Reset {
        didSet { propertyChanged(propName: "recipeClass") }
    }
    
    var recipeId: UInt8 = 0 {
        didSet { propertyChanged(propName: "recipeId") }
    }
    
    var recipeStep: UInt8 = 0 {
        didSet { propertyChanged(propName: "recipeStep") }
    }
    
    private(set) var machineState = MachineState.Idle
    private(set) var ledState: LedState? = nil
    
    init() {
        log.info("Initializing socket...")
        do {
            socket = try Socket.create()
            log.info("Socket has been initialized successfully.")
        } catch let e {
            log.error("Error while trying to create socket.", context: e)
        }
    }

    func connect(timeout: UInt = 1000, onSuccess: (() -> Void)? = nil, onError: ((String) -> Void)? = nil) {
        guard let socket = socket else {
            log.warning("Could not connect to the machine because the socket is not initialized.")
            if let onError = onError {
                onError("Socket is not initialized.")
            }
            return
        }
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            do {
                try socket.connect(to: "10.10.100.254", port: 8899, timeout: timeout)
                log.info("Connection the the machine has been successfully established.")
                if let onSuccess = onSuccess {
                    self.installKeepAliveTimer()
                    self.listen()
                    self.requestUpdate()
                    onSuccess()
                }
            } catch let e {
                log.error("Error while trying to connect to machine.", context: e)
                if let onError = onError {
                    onError(e.localizedDescription)
                }
            }
        }
    }
    
    func updateWithoutTrigger(closure: () -> Void) {
        doUpdate = false
        closure()
        doUpdate = true
    }
    
    private func propertyChanged(propName: String) {
        if doUpdate {
            if !commit() {
                log.warning("Commit after '\(propName)' property changed, resulted in an error.")
            }
        }
    }
    
    private func listen() {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            repeat {
                var readData = Data(capacity: 21)
                do {
                    let readBytes = try self.socket?.read(into: &readData) ?? 0
                
                    if readBytes > 0 {
                        let message = Message(fromData: readData)
                        self.handleMessage(message: message)
                    }
                } catch let e {
                    log.error("Error while reading data.", context: e)
                }
                
            } while self.connectionState == .Connected
        }
    }
    
    func commit() -> Bool {
        let message = Message(messageType: .Control)
        message.commandType = .UpdateValues
        message.minutes = minutes
        message.seconds = seconds
        message.speed = speed
        message.temperature = temperature
        message.recipeId = recipeId
        message.recipeStep = recipeStep
        message.recipeClass = recipeClass
        log.info("Commiting status update...")
        return sendMessage(message: message)
    }
    
    func requestUpdate() {
        let message = Message(messageType: .Query)
        log.info("Requesting an update...")
        if !sendMessage(message: message) {
            log.error("An error occured while requesting an update.")
        }
    }
    
    private func sendMessage(message: Message) -> Bool {
        guard let socket = socket else {
            log.warning("Could not send message because socket was nil.")
            return false
        }
        
        do {
            try socket.write(from: message.toData())
            return true
        } catch let e {
            log.error("Error while trying to send message.", context: e)
            return false
        }
    }
    
    private func handleMessage(message: Message) {
        if message.messageType != .Report {
            log.warning("Was expecting MessageType = Report, but received \(message.messageType)")
            return
        }
        
        updateWithoutTrigger {
            self.minutes = message.minutes
            self.seconds = message.seconds
            self.speed = message.speed
            self.temperature = message.temperature
            self.measuredTemperature = message.measuredTemperature
            self.weight = message.weight
            self.weightStatus = message.weightStatus
            self.recipeClass = message.recipeClass
            self.recipeId = message.recipeId
            self.recipeStep = message.recipeStep
            self.machineState = message.machineState
            self.ledState = message.ledState
        }
        log.info("Successfully updated properties.")
    }
    
    private func installKeepAliveTimer() {
        if let timer = keepAliveTimer {
            timer.invalidate()
        }
        
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 60 * 1000, repeats: true, block: { (timer) in
            let keepAliveObject = Message(messageType: .KeepAlive)
            log.info("Sending keep alive signal...")
            do {
                try self.socket?.write(from: keepAliveObject.toData())
            } catch let e {
                log.error("Error while sending the keep alive signal.", context: e)
            }
        })
    }



}
