//
//  CircleControl.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/29/21.
//

import Foundation
import SwiftUI
import simd

extension GeometryProxy {
    var x: CGFloat {self.size.width}
    var y: CGFloat {self.size.height}
    
    var controlBoundaryDiameter: CGFloat {x*0.6}
    var controlDiameter: CGFloat {x*0.25}
    
    var maxDragDistance: CGFloat {(controlBoundaryDiameter-controlDiameter)*0.5}
    var maxDragDistanceSqrd: CGFloat {maxDragDistance*maxDragDistance}
}

extension DragGesture.Value {
    var x: CGFloat {self.translation.width}
    var y: CGFloat {self.translation.height}
}

struct CircleControlView: View {
    
    @ObservedObject var arController: ARController
    
    var body: some View {
        GeometryReader {(proxy: GeometryProxy) in
            Circle()
                .foregroundColor(Color.black.opacity(0.2))
                .frame(width: proxy.controlBoundaryDiameter, height: proxy.controlBoundaryDiameter, alignment: .center)
                .position(x: proxy.x*0.5, y: proxy.y - proxy.controlBoundaryDiameter*0.5)
            Circle()
                .stroke()
                .frame(width: proxy.controlBoundaryDiameter, height: proxy.controlBoundaryDiameter, alignment: .center)
                .position(x: proxy.x*0.5, y: proxy.y - proxy.controlBoundaryDiameter*0.5)
                .foregroundColor(.black)
            Circle()
                .fill(RadialGradient(gradient: .init(colors: [.white,.gray]), center: .center, startRadius: 0,
                                     endRadius: proxy.controlDiameter*0.5))
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global)
                        .onChanged({(value: DragGesture.Value) in
                            // check if user has dragged past the maxDistance
                            
                            let userVector: SIMD2<Float> = [Float(value.x),Float(value.y)]
                            let userDistanceSquared = simd_length_squared(userVector)
                            
                            if userDistanceSquared > Float(proxy.maxDragDistanceSqrd) {
                                // user dragged too far: we have to normalize
                                let userVectorNormalized = simd_normalize(userVector)
                                
                                arController.xDragProp = CGFloat(userVectorNormalized.x)
                                arController.yDragProp = CGFloat(userVectorNormalized.y)
                                
                            } else {
                                arController.xDragProp = value.x/proxy.maxDragDistance
                                arController.yDragProp = value.y/proxy.maxDragDistance
                            }
                            
                            arController.yDragProp = -arController.yDragProp
                        })
                        .onEnded({(value: DragGesture.Value) in
                            arController.xDragProp = .zero
                            arController.yDragProp = .zero
                        })
                )
                .frame(width: proxy.controlDiameter, height: proxy.controlDiameter, alignment: .center)
                .position(x: proxy.x*0.5 + arController.xDragProp * proxy.maxDragDistance,
                          y: proxy.y - proxy.controlBoundaryDiameter*0.5 - arController.yDragProp*proxy.maxDragDistance)
        }
    }
}
