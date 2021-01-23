//
//  ARController.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import Foundation
import ARKit
import RealityKit

let ballRadius: Float = 0.05

class ARController: ObservableObject {
    
    func serverToLocal(v: Vector) -> simd_float3 {[Float(v.X), height + ballRadius, Float(v.Y)]}
    
    enum State {
        // placing
        case fresh
        case scanning
        case previewing
        
        // placed
        case countDown
        case playing
    }
    
    @Published var state = State.fresh
    
    let view: ARView
     
    let hostID: String
    let clientID: String
    
    @Published var height: Float = 1.0
    
    init() {
        self.view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        runWorldTracking()
    }
    
    private func runWorldTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        view.session.run(config, options: [.removeExistingAnchors, .resetTracking, .stopTrackedRaycasts, .resetSceneReconstruction])
    }
    
    func freshToScanning() {}
    
    func scanningToPreviewing() {}
    
    func previewingToCountDown() {}
    
    func countDownToPlaying() {}
    
}
