//
//  ARController.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import Foundation
import ARKit
import RealityKit
import Combine

class ARControllerHeader {
    
    func runWorldTracking() {fatalError()}
    
    
}

class ARController: MessageReceiver, ObservableObject {
    
    enum State: Hashable {
        // placing
        
        case fresh // looking for place to scan
        case scanning // no plane found but looking for it
        case previewing // found a tentative surface, previewing what the map would look like
        case placed
        case waiting // pressed that is ready to play, notifies server
        
        // placed
        case countDown
        case playing
        case postGame
    }
    
    @Published var height: Float = 0.2
    @Published var diameter: Float = 0.2
    
    @Published var state = State.fresh
    @Published var hostWon: Bool = false // used during postGame
    
    @Published var opponentPlayAgain = false // used during postGame
    @Published var requestedToPlayAgain = false
    @Published var opponentWaiting = false // used during fresh - placed
    
    @Published var countDownTime: String = "5.00"
    
    @Published var xDragProp: CGFloat = 0
    @Published var yDragProp: CGFloat = 0
    
    let view: ARView
    var map: ARMap! = nil
    
    var subscriber: AnyCancellable! = nil
    
    let hostID: String
    let clientID: String
    
    let hosting: Bool
    
    init(hostID: String, clientID: String, hosting: Bool) {
        
        self.hostID = hostID
        self.clientID = clientID
        
        self.hosting = hosting
        
        self.view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        // we are now initialized
        self.subscriber = view.scene.publisher(for: SceneEvents.Update.self).sink(receiveValue: handleUpdate(dt:))
        self.map = ARMap(controller: self)
        runWorldTracking()
    }
    
    func runWorldTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        view.session.run(config, options: [.removeExistingAnchors, .resetTracking, .stopTrackedRaycasts, .resetSceneReconstruction])
    }
    
    // takes where the camera and ball are relative to the map and spits out a vector in game space showing that difference
    func cameraToBallInGameSpace(host: Bool) -> simd_float2 {
        // get camera to ball in map space
        let ball = Transform(matrix: host ? map.hostBall.transformMatrix(relativeTo: map) : map.clientBall.transformMatrix(relativeTo: map)).translation
        let camera = map.convert(position: view.cameraTransform.translation, from: nil)
        let diff = ball-camera
        
        // map space to game space
        let newVec: simd_float2 = [diff.x,diff.z]
        guard newVec.x != 0 && newVec.y == 0 else {return newVec}
        return simd_normalize(newVec)
    }
    
    // takes our drag proportions and spits out a DV in game space for our balls
    func getCurrentDV(dt: Float) -> Vector {
        let maxAcceleration: Float = 1.0
        let yVec = cameraToBallInGameSpace(host: hosting)
        let xVec: simd_float2 = [-yVec.y,yVec.x]
        let gameAcceleration: simd_float2 = Float(yDragProp)*yVec + Float(xDragProp)*xVec
        return (gameAcceleration*dt*maxAcceleration).toVector()
    }
    
    // assert that we're in state start, switch to state to
    func assert(_ start: State, _ to: State) {
        // occured on countdown
        guard self.state == start else {fatalError()}
        self.state = to
    }
    
    // send message to server that we want to play again
    func playAgain() {
        appController.tcpConn.sendMessage(message: .playAgain)
        self.requestedToPlayAgain = true
    }
    
    func freshToScanning() {
        assert(State.fresh,State.scanning)
    }
    
    func userWon() -> Bool {hosting == hostWon}
    
    func winnerName() -> String {hostWon ? hostID : clientID}
        
    func scanningToPreviewing() {
        assert(State.scanning,State.previewing)
    }
    
    func previewingToPlaced() {
        assert(State.previewing,State.placed)
        
    }
    
    func placedToWaiting() {
        assert(State.placed, State.waiting)
        appController.tcpConn.sendMessage(message: .doneScanning)
    }
        
    func waitingToCountDown() {
        assert(State.waiting,State.countDown)
        opponentWaiting = false
    }
        
    func countDownToPlaying() {
        assert(State.countDown, State.playing)
    }
    
    // TODO:
    func playingToPostGame(hostWon: Bool) {
        assert(State.playing,State.postGame)
        map.resetBallPositions()
        self.hostWon = hostWon
    }
    
    // TODO:
    func postGameToCountDown() {
        assert(State.postGame,State.countDown)
        opponentPlayAgain = false
        self.hostWon = false
        self.requestedToPlayAgain = false
        countDownTime = "5.00"
    }
    
    func sendAccelerationMessage(dt: Float) {
        if xDragProp == 0 && yDragProp == 0 {return}
        
        let dv = getCurrentDV(dt: dt)
        print(dv.X,dv.Y)
        appController.tcpConn.sendMessage(message: .accelerated(dv))
    }
    
    // UNFINISHED: CLOSELY EXAMINE REALITYKITTEST'S ARVIEW2
    func handleUpdate(dt: SceneEvents.Update) {
        switch state {
        case .fresh:
            break
        case .scanning:
            scanningRayCast()
        case .previewing:
            previewingRayCast()
            map.updateDimensions()
        case .waiting:
            break
        case .placed:
            map.updateDimensions()
        case .countDown:
            break
        case .playing:
            sendAccelerationMessage(dt: Float(dt.deltaTime))
            break
        case .postGame:
            break
        }
    }
    
    // UNFINISHED:
    // appController catches opponentLeft
    func receiveMessage(message: ServerMessage) {
        switch message {
        case .opponentPlayAgain:
            opponentPlayAgain = true
        case .countDownStart:
            
            if state == .waiting {
                waitingToCountDown()
            } else {
                postGameToCountDown()
            }
        case .gameState(let gameState):
            map.processGameUpdate(update: gameState)
        case .countDownTime(let nanoSeconds):
            // try this first:
            // let x = String((nanoSeconds / 1_000_000_000).toChar())
            // if self.countDownTime != x {self.countDownTime = x}
            self.countDownTime = nanoSecondsToString(nanoSeconds)
        case .startGame:
            countDownToPlaying()
        case .clientWon:
            playingToPostGame(hostWon: false)
        case .hostWon:
            playingToPostGame(hostWon: true)
        case .opponentScanned:
            self.opponentWaiting = true
        default: break
        }
    }
}

extension ARController {
    
    // precondition: raycast while we're scanning
    // postcondition: if we found a surface, we're previewing now and the map is attached to the spot
    private func scanningRayCast() {
        // while prepreviewing, spam this initial raycast
        switch view.session.currentFrame?.camera.trackingState {
        case .normal: break
        default:return
        }
        
        guard let result = view.raycast(from: view.center, allowing: .existingPlaneGeometry, alignment: .horizontal).first else {return}
        defer {
            scanningToPreviewing()
        }
        
        let raycastTransform = Transform(matrix: result.worldTransform)
        
        // update map preview to be at anchor location
        map.transform.translation = raycastTransform.translation
        map.transform.rotation = raycastTransform.rotation.rotationInXZ()
        
        // if we're not hosting, turn the map around
        if !hosting {
            let halfway = simd_quatf(angle: .pi, axis: [0,1,0])
            map.transform.rotation = halfway*map.transform.rotation
        }
        
        // add the anchor
        let anchorEntity = AnchorEntity(raycastResult: result)
        
        view.scene.addAnchor(anchorEntity)
        anchorEntity.addChild(map, preservingWorldTransform: true)
    }
    
    // precondition: raycast while we're previewing
    // postcondition: if our raycast finds solid ground,
    // change map location according to our location and where the raycast intersects the ground
    private func previewingRayCast() {
        guard let result = view.raycast(from: view.center, allowing: .existingPlaneGeometry, alignment: .horizontal).first else {return}
        let raycastTransform = Transform(matrix: result.worldTransform)
        
        var transform = Transform()
        transform.translation = raycastTransform.translation
        transform.rotation = raycastTransform.rotation.rotationInXZ()
        
        if !hosting {
            let halfway = simd_quatf(angle: .pi, axis: [0,1,0])
            transform.rotation = halfway*transform.rotation
        }
        
        map.setTransformMatrix(transform.matrix, relativeTo: nil)
    }
}
