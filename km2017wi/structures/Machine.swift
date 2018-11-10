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

    init() {
        log.info("Initializing socket...")
        do {
            socket = try Socket.create()
            log.info("Socket has been initialized successfully.")
        } catch let e {
            log.error("Error while trying to create socket.", context: e)
        }
    }

    func connect(timeout: UInt = 1000, onSuccess: (() -> Void)?, onError: ((String) -> Void)?) {
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
    
    private func handleMessage(message: Message) {
        
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
