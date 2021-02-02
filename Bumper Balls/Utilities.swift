//
//  Utilities.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/26/21.
//

import SwiftUI
import Combine
import simd

let encoder = JSONEncoder()
let decoder = JSONDecoder()

extension Int {
    func toChar() -> Character {["0","1","2","3","4","5","6","7","8","9"][self]}
}

func nanoSecondsToString(_ nanoSeconds: Int) -> String {
    let centiSeconds = nanoSeconds/10000000
    let seconds = centiSeconds/100
    var countDownTime = String()
    countDownTime.reserveCapacity(4)
    countDownTime.append(seconds.toChar())
    countDownTime.append("." as Character)
    countDownTime.append(((centiSeconds/10)%10).toChar())
    countDownTime.append((centiSeconds%10).toChar())
    return countDownTime
}

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
    
    static var keyboardShowing: AnyPublisher<Bool, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map {_ in true}
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map {_ in false}
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension simd_float2 {
    func toVector() -> Vector {
        return Vector(X: Double(x), Y: Double(y))
    }
}

extension simd_quatf {
    
    static let identity = Self.init(angle: 0, axis: [1,0,0])
    
    func rotationInXZ() -> simd_quatf {
        let rotated = self.act([0,0,-1])
        
        var xzVector = SIMD2<Float>(-rotated.z, -rotated.x)
        guard xzVector != .zero else {return .identity}
        xzVector = simd_normalize(xzVector)
        
        var angle: Float
        
        switch xzVector.x {
        case let x where x > 0.9999:
            angle = 0
        case let x where ((-0.0001)...(0.0001)).contains(x) :
            if xzVector.y < 0 {
                angle = .pi * 0.5
            } else {
                angle = -0.5 * Float.pi
            }
        case let x where x < -0.9999:
            angle = .pi
        case let x where x > 0:
            angle = atan(xzVector.y/xzVector.x)
        case let x where x < 0:
            angle = .pi + atan(xzVector.y/xzVector.x)
        default:
            fatalError()
        }
        
        return .init(angle: angle, axis: [0,1,0])
    }
}
