//
//  UndecidedData.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/25/21.
//

import Foundation
import Network
import SwiftUI

class UndecidedData: MessageReceiver, ObservableObject {
    
    @Published var errorMessage: String?
    
    var joiningOther: String? = nil
    @Published var offeringToHost = false
    
    @Published var tenJoinable = [String]()
    
    init(errorMessage: String?) {
        self.errorMessage = errorMessage
        reloadTenJoinable()
    }
    
    func startOfferingToHost() {
        appController.tcpConn.sendMessage(message: .hostGame)
        offeringToHost = true
    }
    
    func stopOfferingToHost() {
        appController.tcpConn.sendMessage(message: .reset)
        offeringToHost = false
    }
    
    func reloadTenJoinable() {
        appController.tcpConn.sendMessage(message: .requestHosts)
    }
    
    func joinGame(id: String) {
        offeringToHost = false
        joiningOther = id
        appController.tcpConn.sendMessage(message: .joinGame(id))
    }
    
    func startGame(clientID: String) {
        appController.toARController(hostID: offeringToHost ? appController.username : joiningOther!, clientID: clientID, hosting: offeringToHost)
    }
    
    // appController catches opponentLeft
    func receiveMessage(message: ServerMessage) {
        switch message {
        case .tenJoinable(let tenJoinable):
            self.tenJoinable = tenJoinable
        case .startScanning(let clientID):
            startGame(clientID: clientID)
        case .joinFailedInactive:
            errorMessage = "Game no longer active!"
        case .joinFailedOtherJoined:
            errorMessage = "Another user joined game!"
        default: break
        }
    }
}
