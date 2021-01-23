//
//  NetworkCommunicator.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import Foundation
import Network

let encoder = JSONEncoder()
let decoder = JSONDecoder()

enum ServerConnection {
    
    enum State: Int {
        case inactive = -1
        case choosingUsername = 0
        case undecided
        case waitingClient
        case scanning
        case countDown
        case inGame
        case postGame
    }
    
    enum Handler {
        
        static func choosingUsername(message: ServerMessage) {
            switch message {
            case .goodUsername:
                <#code#>
            case .joinFailedInactive:
                <#code#>
            case .joinFailedOtherJoined:
                
            default:
                return
            }
        }
        
        static func undecided(message: ServerMessage) {
            
        }
        
        static func waitingClient(message: ServerMessage)  {
            
        }
        
        static func scanning(message: ServerMessage) {
            
        }
        
        static func countDown(message: ServerMessage) {
            
        }
        
        static func inGame(message: ServerMessage) {
            
        }
        
        static func postGame(message: ServerMessage) {
            
        }
    }
    
    static var state = State.inactive
    
    static let host = "localhost"
    static let portInt: UInt16 = 8001
    
    static let handlers: [(ServerMessage) -> ()] = [Handler.choosingUsername(message:),Handler.undecided(message:)]
    
    static let connection: NWConnection = {
        let host = NWEndpoint.Host("localhost")
        let port = NWEndpoint.Port(rawValue: portInt)!
        let connection = NWConnection(host: host, port: port, using: .tcp)
        connection.stateUpdateHandler = stateDidChange(to:)
        return connection
    }()
    
    
    static func listenForData() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1<<13, completion: receivedData(data:context:complete:error:))
    }
    
    static func start(errorMessage: String? = nil) {
        print("start")
        print("connecting to: \(host):\(portInt)")
        print("state: \(connection.state)")
        
        connection.start(queue: DispatchQueue.main)
        listenForData()
        state = .choosingUsername
        toView(ChooseUsernameView(errorMessage: errorMessage))
    }
    
    static func stop() {
        print("stop")
        connection.cancel()
        state = .inactive
    }
    
    static func reset(errorMessage: String) {
        print("reset")
        stop()
        start(errorMessage: errorMessage)
    }
    
    static func send(data: Data) {
        print("Sending Data to server")
        connection.send(content: data, completion:  .contentProcessed(
                            {error in
                                if let error = error {reset(errorMessage: error.localizedDescription)}
                                else  {print("Sent Data to server")}
                            }))
    }
    
    private static func receivedData(data: Data?, context: NWConnection.ContentContext?, complete: Bool, error: NWError?) {
        if let error = error {
            reset(errorMessage: error.localizedDescription)
            return
        } else if complete {
            reset(errorMessage: "Server closed connection")
            return
        }
        
        guard let data = data, let message = ServerMessage(data: data) else {reset(errorMessage: "Received Garbled Data"); return}
        
        defer {self.listenForData()}
        
        (handlers[state.rawValue])(message)
        
    }
    
    private static func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            print("Waiting:",error)
        case .ready:
            print("Client Connected to Server")
        case .failed(let error):
            reset(errorMessage: error.localizedDescription)
        default:
            break
        }
    }
}
