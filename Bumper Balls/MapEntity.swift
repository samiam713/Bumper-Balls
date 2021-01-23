//
//  PrefabStore.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/22/21.
//

import Foundation
import RealityKit

// while scanning, you can change size. Once you're done, stop

class MapEntity: Entity, ObservableObject {
    
    let hostBall: Entity
    let clientBall: Entity
    
    var height: Double = 1.0
    var diameter: Double = 1.0
    
    required init() {
        let prefabs = try! Experience.loadPrefabs()
        
        super.init()
    }
    
    func setHostPosition(vector: Vector) {
        
    }
    
    func set
}
