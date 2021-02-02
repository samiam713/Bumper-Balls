//
//  LoggingInData.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/25/21.
//

import Foundation

class LoggingInData: MessageReceiver, ObservableObject {
    
    enum State: Equatable {
        case submittingUsername
        case processingUsername
    }
    
    @Published var state = State.submittingUsername
    @Published var errorMessage: String?
    @Published var username: String = ""
    
    init(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    func attemptLogin() {
        guard (1...10).contains(username.count) else {
            errorMessage = "Username doesn't have 1-10 characters"
            return
        }
        self.state = .processingUsername
        appController.attemptLogin(username: username)
    }
    
    // appController catches opponentLeft
    func receiveMessage(message: ServerMessage) {
        switch message {
        case .goodUsername:
            appController.toUndecided(errorMessage: nil)
        case .duplicateUser:
            state = .submittingUsername
            errorMessage = "Username already in use"
        default: return
        }
    }
}
