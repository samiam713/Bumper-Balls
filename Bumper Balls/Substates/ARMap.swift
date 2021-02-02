//
//  PrefabStore.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/22/21.
//

import Foundation
import RealityKit

let initialRadius: Float = 0.5
let ballRadius: Float = 0.05
let initialHeight: Float = 1.0

class ARMap: Entity {
    
    static let prefabs = try! Experience.loadPrefabs()
    
    static let cylinder = prefabs.cylinder!
    static let hostBall = prefabs.hostBall!
    static let clientBall = prefabs.clientBall!
    
    let cylinder: Entity
    let hostBall: Entity
    let clientBall: Entity
    let ballTop = Entity()
    let spinner: Spinner
    
    unowned var controller: ARController
    
    required init(controller: ARController) {
        
        let spinnerComponentRaw = Self.prefabs.spinnerComponent!.clone(recursive: true)
        spinnerComponentRaw.transform.translation = [0.0344,-0.05,0]
        let spinnerComponent = Entity()
        spinnerComponent.addChild(spinnerComponentRaw)
        
        spinner = Spinner(spinnerComponent: spinnerComponent)
        cylinder = Self.cylinder
        hostBall = Self.hostBall
        clientBall = Self.clientBall
        
        self.controller = controller
        
        super.init()
        
        // deal with ball top
        self.addChild(ballTop)
        
        // deal with spinner
        spinner.transform.translation = [0,ballRadius,0]
        ballTop.addChild(spinner)
        
        // deal with balls
        ballTop.addChild(hostBall)
        ballTop.addChild(clientBall)

        resetBallPositions()
        
        // deal with cylinder
        self.addChild(cylinder)
        
        // set everything to proper position/scales
        updateDimensions()
    }
    
    required init() {fatalError("init() has not been implemented")}
    
    func resetBallPositions() {
        hostBall.transform.translation = [0,ballRadius, initialRadius * 0.75]
        clientBall.transform.translation = [0,ballRadius, -initialRadius * 0.75]
    }
    
    // process game update
    func processGameUpdate(update: ServerMessage.GameStateJSON) {
        hostBall.transform.translation = serverToLocal(v: update.Host)
        clientBall.transform.translation = serverToLocal(v: update.Client)
        spinner.shrinkAndSpin(radius: Float(update.Radius))
    }
    
    // helper functions for processGameUpdate
    func serverToLocal(v: Vector) -> simd_float3 {[Float(v.X), ballRadius, Float(v.Y)]}
    
    // updates game dimensins while previewing
    func updateDimensions() {
        let height = controller.height
        let diameter = controller.diameter
        
        // update top based on height, diameter
        ballTop.transform.translation = [0,height,0]
        ballTop.transform.scale = simd_float3(repeating: diameter)
        
        // update cylinder based on height, diameter
        cylinder.transform.translation = [0,0.5*height,0]
        cylinder.transform.scale = [diameter, height, diameter]
    }
}

class Spinner: Entity {
    
    let numComponents = 36
    var unitDirections = [simd_float3]()
    var spinnerComponents = [Entity]()
    
    required init() {fatalError()}
    
    // angle from x to z
    init(spinnerComponent: Entity) {
        super.init()
        
        unitDirections.reserveCapacity(numComponents)
        spinnerComponents.reserveCapacity(numComponents)
        
        let unitX = [1,0,0] as simd_float3
        
        for spinnerComponentIndex in 0..<numComponents {
            let rotation = simd_quatf(angle: 2*Float.pi*Float(spinnerComponentIndex)/Float(numComponents), axis: [0,1,0])
            unitDirections.append(rotation.act(unitX))
            
            let newSpinnerComponent = spinnerComponent.clone(recursive: true)
            if spinnerComponentIndex.isMultiple(of: 2) {
                newSpinnerComponent.transform.rotation = .init(angle: .pi, axis: [1,0,0])
            }
            newSpinnerComponent.transform.rotation = rotation*newSpinnerComponent.transform.rotation
            self.addChild(newSpinnerComponent)
            spinnerComponents.append(newSpinnerComponent)
        }
        
        shrinkAndSpin(radius: initialRadius)
    }
    
    func shrinkAndSpin(radius: Float) {
        
        let gameProp = (0.5 - radius)/0.5
        
        // spin
        let rotationProportion = 10*gameProp
        let rotationAngle = 2.0*Float.pi*rotationProportion
        self.transform.rotation = simd_quatf(angle: rotationAngle, axis: [0,1,0])
        
        // shrink
        for i in 0..<numComponents {
            spinnerComponents[i].transform.translation = radius*unitDirections[i]
            
            // guess and check zf
            let zi: Float = 1.0
            let zf: Float = 0.1
            transform.scale = [1,1,zi+(zf-zi)*gameProp]
        }
    }
}
