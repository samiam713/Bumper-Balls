//
//  Messages.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import Foundation

struct Vector: Codable {
    let X: Float64
    let Y: Float64
}

let space: UInt8 = (" " as Character).asciiValue!
let newLine: UInt8 = ("\n" as Character).asciiValue!

enum ServerMessage {
    
    struct GameStateJSON: Codable {
        let Host: Vector
        let Client: Vector
        let Radius: Float64
    }
    
    case gameState(GameStateJSON)
    case startScanning
    case joinFailedInactive
    case joinFailedOtherJoined
    case duplicateUser
    case opponentLeft
    case countDownTime(Int)
    case startGame
    case clientWon
    case hostWon
    case countDownStart
    case goodUsername
    case opponentScanned
    case opponentPlayAgain
    case tenJoinable([String])
        
    init?(data: Data) {
        // guard let string = String(data: data, encoding: .utf8) else {return nil}
        guard let first = data.first else {return nil}
        switch first {
        case 97: // a
            let jsonData = data.dropFirst(2)
            guard let gameStateJSON = try? decoder.decode(GameStateJSON.self, from: jsonData) else {return nil}
            self = .gameState(gameStateJSON)
        case 98: // b
            self = .startScanning
        case 99:
            self = .joinFailedInactive
        case 100: // d
            self = .joinFailedOtherJoined
        case 101: // e
            self = .duplicateUser
        case 102:
            self = .opponentLeft
        case 103:
            guard let intString = String(data: data.dropFirst(2), encoding: .utf8), let int = Int(intString) else {return nil}
            self = .countDownTime(int)
        case 104:
            self = .startGame
        case 105:
            self = .clientWon
        case 106:
            self = .hostWon
        case 107:
            self = .countDownStart
        case 108:
            self = .goodUsername
        case 109:
            self = .opponentScanned
        case 110:
            self = .opponentPlayAgain
        case 111:  // o
            let tenJoinableData = data.dropFirst(2)
            guard let tenJoinable = try? decoder.decode([String].self, from: tenJoinableData) else {return nil}
            self = .tenJoinable(tenJoinable)
        default:
            return nil
        }
    }
}

enum ClientMessage {
    case accelerated(Vector) // 97 : a
    case hostGame
    case joinGame(String)
    case doneScanning
    case playAgain
    case requestHosts
    case reset // 103 : g
    
    func asData() -> Data {
        var data = Data()
        data.reserveCapacity(2)
        switch self {
        case .accelerated(let v):
            data.append(97)
            data.append(space)
            data.append(try! encoder.encode(v))
            data.append(newLine)
        case .hostGame:
            data.append(98)
            data.append(newLine)
        case .joinGame(let id):
            data.append(99)
            data.append(space)
            data.append(id.data(using: .utf8)!)
            data.append(newLine)
        case .doneScanning:
            data.append(100)
            data.append(newLine)
        case .playAgain:
            data.append(101)
            data.append(newLine)
        case .requestHosts:
            data.append(102)
            data.append(newLine)
        case .reset:
            data.append(103)
            data.append(newLine)
        }
        return data
    }
}
