//
//  TCPConn.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/25/21.
//

import Foundation
import Network

protocol TCPConnDelegate: MessageReceiver {
    func connectedToServer(error: Error?)
    func messageSendFail(error: Error)
    func messageReceiveFail(error: Error)
    
    func connectionClosed()
   
}

protocol MessageReceiver: AnyObject {
    func receiveMessage(message: ServerMessage)
}

class TCPConn {
    
    var active = false
    let connection: NWConnection
    unowned let delegate: TCPConnDelegate
    
    
    init(host: NWEndpoint.Host, port: NWEndpoint.Port, delegate: TCPConnDelegate) {
        self.connection = NWConnection(host: host, port: port, using: .tcp)
        self.delegate = delegate
        connection.stateUpdateHandler = stateDidChange(to:)
        
    }
    
    func start() {
        connection.start(queue: DispatchQueue.main)
        listenForData()
        active = true
    }
    
    func stop() {
        connection.cancel()
        active = false
    }
    
    func sendMessage(message: ClientMessage) {send(data: message.asData())}
    
    func send(data: Data) {
        connection.send(content: data, completion:  .contentProcessed(
                            {error in
                                if let error = error {self.delegate.messageSendFail(error: error)}    
                            }))
    }
    
    private func listenForData() {
    
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1<<13, completion: self.receivedData(data:context:complete:error:))
    }
    
    private func receivedData(data: Data?, context: NWConnection.ContentContext?, complete: Bool, error: NWError?) {
        if let error = error {
            stop()
            delegate.messageReceiveFail(error: error)
            return
        } else if complete {
            stop()
            delegate.connectionClosed()
            return
        }
        
        guard let data = data else {
            stop()
            delegate.messageReceiveFail(error: NSError(domain: "Got nil data", code: 0))
            return
        }
        
        guard let message = ServerMessage(data: data) else {
            if let dataString = String(bytes: data, encoding: .utf8) {
                delegate.messageReceiveFail(error: NSError(domain: "Couldn't decode message from data \(dataString)", code: 0))
            } else {
                delegate.messageReceiveFail(error: NSError(domain: "Couldn't decode data into message or string", code: 0))
            }
            return
        }
        
        delegate.receiveMessage(message: message)
        self.listenForData()
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        print(state)
        switch state {
        case .waiting(let error):
            stop()
            delegate.connectedToServer(error: error)
        case .ready:
            // listenForData()
            delegate.connectedToServer(error: nil)
        case .failed(let error):
            stop()
            delegate.connectedToServer(error: error)
        default:
            break
        }
    }
}
