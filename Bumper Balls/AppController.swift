//
//  NetworkCommunicator.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import Foundation
import Network


var appController: AppController! = nil

class AppController: ObservableObject {
    
    enum State: Int {
        case loggingIn = 0 // connection active OR inactive
        case undecided
        case waitingClient
        case scanning
        case countDown
        case inGame
        case postGame
    }
    
    // resettable
    var username: String = ""
    
    var tcpConn: TCPConn! = nil
    var substate: MessageReceiver! = nil
    
    init() {
        toLoggingIn(errorMessage: nil)
        self.tcpConn = TCPConn(host: "3.22.186.9", port: 8001, delegate: self)
    }
    
    func connectionStoppedNeedToReset(explanation: String) {
        toLoggingIn(errorMessage: explanation)
    }
    
    
    // send whenever a game exists and you  want  to get back to the basics
    func abandonOpponent() {
        toUndecided(errorMessage: nil)
        tcpConn.sendMessage(message: .reset)
    }
    
    func getAbandoned() {
        toUndecided(errorMessage: "Opponent Left")
    }
    
    func attemptLogin(username: String) {
        self.username = username
        if !tcpConn.active {tcpConn.start()}
        
        tcpConn.send(data: (appController.username+"\n").data(using: .utf8)!)
    }
}

// substate changes
extension AppController {
    func toLoggingIn(errorMessage: String?) {
        let loggingInData = LoggingInData(errorMessage: errorMessage)
        toView(LoggingInView(loggingInData: loggingInData))
        substate = loggingInData
    }
    
    func toUndecided(errorMessage: String?) {
        let undecidedData = UndecidedData(errorMessage: errorMessage)
        toView(UndecidedView(undecidedData: undecidedData))
        substate = undecidedData
    }
    
    func toARController(hostID: String, clientID: String, hosting: Bool) {
        let arController = ARController(hostID: hostID, clientID: clientID, hosting: hosting)
        toView(ARControllerView(arController: arController))
        self.substate = arController
    }
}


// events
extension AppController: TCPConnDelegate {
    func connectedToServer(error: Error?) {
        if let _ = error {
            connectionStoppedNeedToReset(explanation: "Failed Connecting To Server")
        }
    }
    
    func messageSendFail(error: Error) {
        connectionStoppedNeedToReset(explanation: "Failed Sending Data To Server")
    }
    
    func messageReceiveFail(error: Error) {
        connectionStoppedNeedToReset(explanation: "Receive Error:\n\(error.localizedDescription)")
    }
    
    func connectionClosed() {
        connectionStoppedNeedToReset(explanation: "Server Disconnected")
    }
    
    func receiveMessage(message: ServerMessage) {
        print("RECEIVED MESSAGE")
        switch message {
        case .opponentLeft:
            getAbandoned()
        default:
            substate.receiveMessage(message: message)
        }
    }
}

