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
            guard let socket = socket else { return .Disconnected }
            
            if socket.isActive { return .Connected }
            else { return .Disconnected }
        }
    }

    var socket: Socket? = nil
    private var keepAliveTimer: Timer? = nil
    private var reconnectTimer: Timer? = nil
    private var doUpdate: Bool = true
    private let socketLockQueue = DispatchQueue(label: "socketLockQueue")
    
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

    func connect(timeout: UInt = 1000, onError: ((String) -> Void)? = nil, onSuccess: (() -> Void)? = nil) {
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
                log.info("Connection the the machine has been established successfully.")
                self.installKeepAliveTimer()
                self.listen()
                self.requestUpdate()
                if let onSuccess = onSuccess {
                    queue.sync(execute: onSuccess)
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
        if doUpdate {
            doUpdate = false
            closure()
            doUpdate = true
        } else {
            closure()
        }
    }
    
    func startWeight() {
        let message = Message(messageType: .Control)
        message.commandType = .WeightStart
        if !sendMessage(message: message) {
            log.error("Error while sending start weight command.")
        }
    }
    
    func stopWeight() {
        let message = Message(messageType: .Control)
        message.commandType = .WeightStop
        
        if !sendMessage(message: message) {
            log.error("Error while sending stop weight command.")
        }
    }
    
    func tareWeight() {
        let message = Message(messageType: .Control)
        message.commandType = .WeightTare
        if !sendMessage(message: message) {
            log.error("Error while sending tare weight command.")
        }
    }
    
    func selectProgram(program: FixedProgram) {
        updateWithoutTrigger {
            self.minutes = 0
            self.seconds = 0
            self.speed = 0
            self.temperature = 0
            self.recipeClass = RecipeClass.FixedProgram
            self.recipeId = program.rawValue
            self.recipeStep = 0
        }
        if !commit() {
            log.error("Error while selecting program.")
        }
    }
    
    func start() {
        let message = Message(messageType: .Control)
        message.commandType = .Start
        log.info("Starting machine...")
        if !sendMessage(message: message) {
            log.error("Error while starting machine.")
        }
    }
    
    func stop() {
        let message = Message(messageType: .Control)
        message.commandType = .Stop
        log.info("Stopping machine...")
        if !sendMessage(message: message) {
            log.error("Error while stopping machine.")
        }
    }
    
    func pause() {
        let message = Message(messageType: .Control)
        message.commandType = .Pause
        log.info("Pausing machine...")
        if !sendMessage(message: message) {
            log.error("Error while pausing machine.")
        }
    }
    
    func reset() {
        updateWithoutTrigger {
            self.minutes = 0
            self.seconds = 0
            self.temperature = 0
            self.speed = 0
            self.recipeClass = .Reset
            self.recipeId = 0
            self.recipeStep = 0
        }
        if !commit() {
            log.error("Error while reseting.")
        }
    }
    
    private func propertyChanged(propName: String) {
        if doUpdate {
            if !commit() {
                log.warning("Commit after '\(propName)' property changed, resulted in an error.")
            }
        }
    }
    
    private func listen() {
        guard let socket = socket else {
            log.error("Cannot listen because socket is not initialized.")
            return
        }
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            repeat {
                var readData = Data(capacity: 21)
                do {
                    let readWrite: (readable: Bool, writable: Bool) = try socket.isReadableOrWritable(waitForever: true, timeout: 10000)
                    if readWrite.readable {
                        let readBytes = try socket.read(into: &readData)
                
                        if readBytes > 0 {
                            let message = Message(fromData: readData)
                            self.handleMessage(message: message)
                        }
                    }
                } catch let e {
                    log.error("Error while reading data.", context: e)
                    self.onError()
                    break
                }
                
            } while self.connectionState == .Connected
            log.debug("Broke out of listen-loop.")
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
            let readWrite: (readable: Bool, writable: Bool) = try socket.isReadableOrWritable(waitForever: true, timeout: 10000)
            if readWrite.writable {
                return try socketLockQueue.sync { () -> Bool in
                    try socket.write(from: message.toData())
                    Thread.sleep(forTimeInterval: 0.1)
                    return true
                }
            }
            return false
        } catch let e {
            log.error("Error while trying to send message.", context: e)
            onError()
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
        let queue = DispatchQueue.main
        
        queue.sync {
            if let timer = self.keepAliveTimer {
                timer.invalidate()
            }
            
            self.keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { (timer) in
                let keepAliveObject = Message(messageType: .KeepAlive)
                log.info("Sending keep alive signal...")
                if !self.sendMessage(message: keepAliveObject) {
                    log.error("Error while sending the keep alive signal.")
                }
            })
        }
    }

    private func onError() {
        guard socket != nil else { return }
        
        if let timer = self.reconnectTimer {
            timer.invalidate()
        }
        
        if connectionState == .Disconnected {
            reconnectTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                self.connect(onSuccess: {
                    log.info("Connection has been restored successfully.")
                    self.reconnectTimer?.invalidate()
                })
            })
        }
    }


}
