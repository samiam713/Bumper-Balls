//
//  ContentView.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import SwiftUI
import RealityKit

struct ARControllerView: View {
    
    let arController: ARController
    
    var body: some View {
        ARViewContainer(arView: arController.view)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let arView: ARView
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func makeUIView(context: Context) -> ARView {arView}
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}
