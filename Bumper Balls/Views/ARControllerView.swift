//
//  ContentView.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import SwiftUI
import RealityKit
import Combine

func xImage() -> some View {Image(systemName: "x.circle.fill").font(.title2).foregroundColor(.red)}
func checkImage() -> some View {Image(systemName: "checkmark.circle.fill").font(.title2).foregroundColor(.green)}

struct ARControllerView: View {
    
    @ObservedObject var arController: ARController
    
    var body: some View {
        GeometryReader {(proxy: GeometryProxy) in
            ZStack {
                ARViewContainer(arView: arController.view)
                    .edgesIgnoringSafeArea(.all)
                ARControllerStateView(arController: arController)
                    .frame(width: proxy.x*(2/3))
                if arController.state == .playing {
                    CircleControlView(arController: arController)
                }
            }
        }
        .resetWrapper()
    }
}

struct ARControllerStateView: View {
    
    let displayIfOpponentWaiting: Set<ARController.State> = [ARController.State.fresh,ARController.State.scanning,ARController.State.previewing,ARController.State.placed]
    
    @ObservedObject var arController: ARController
    
    // DECIDE HOW TO MAKE THIS MORE AESTHETIC...BUTTONS/TEXT OF SIMILAR SIZE?
    var body: some View {
        GeometryReader {(proxy: GeometryProxy) in
            VStack {
                Spacer()
                if (displayIfOpponentWaiting.contains(arController.state)) {
                    HStack {
                        Text("Opponent Waiting:")
                        if arController.opponentWaiting {
                            checkImage()
                        } else {
                            xImage()
                        }
                    }
                }
                if arController.state == .fresh {
                    Text("Start Scanning")
                        .foregroundColor(Color("Primary"))
                        .roundedRectangleButton(action: self.arController.freshToScanning)
                        .frame(height: proxy.y/12)
                }
                else if arController.state == .scanning {
                    Text("Scan flat surface with camera")
                        .foregroundColor(Color("Primary"))
                        .roundedRectangleEffectDefault()
                        .frame(height: proxy.y/12)
                }
                else if arController.state == .previewing {
                    Text("Place Map")
                        .foregroundColor(Color("Primary"))
                        .roundedRectangleButton(action: self.arController.previewingToPlaced)
                        .frame(height: proxy.y/12)
                }
                else if arController.state == .placed {
                    ("Ready to play?")
                        .toView()
                        .frame(height: proxy.y/12)
                    Text("Ready!")
                        .foregroundColor(Color("Primary"))
                        .roundedRectangleButton(action: self.arController.placedToWaiting)
                        .frame(height: proxy.y/12)
                }
                else if arController.state == .waiting {
                    ("Opponent getting ready")
                        .toView()
                        .frame(height: proxy.y/12)
                }
                else if arController.state == .countDown {
                    (arController.countDownTime)
                        .toView()
                        .frame(height: proxy.y/12)
                }
                // if we're playing, we just show the control view higher up in the view heirarchy
                else if arController.state == .postGame {
                    HStack {
                        Text("Opponent Wants to Play Again:")
                        if arController.opponentPlayAgain {
                            checkImage()
                        } else {
                            xImage()
                        }
                    }
                    .foregroundColor(Color("Primary"))
                    .roundedRectangleEffectDefault()
                    .frame(height: proxy.y/12)
                    
                    VStack {
                        Text("\(arController.userWon() ? "YOU" : arController.winnerName()) WON!!")
                            .font(.title)
                            .frame(height: proxy.y/12)
                        
                        Spacer()
                        
                        Text(arController.userWon() ? "Congrats!" : "...sorry")
                            .font(.title)
                            .foregroundColor(arController.userWon() ? Color.green : Color.red)
                            .frame(height: proxy.y/12)
                    }
                    .roundedRectangleEffect(color: .gray)
                    .frame(height: proxy.y/6)
                    
                    if !arController.requestedToPlayAgain {
                        Text("Play Again")
                            .foregroundColor(Color("Primary"))
                            .roundedRectangleButton(action: self.arController.playAgain)
                            .frame(height: proxy.y/12)
                    }
                }
                
                // previewing or placed, we can edit dimensions
                if arController.state == ARController.State.previewing || arController.state == ARController.State.placed {
                    VStack {
                        Slider(value: $arController.diameter, in: (0.1)...(2.0))
                        Text("Diameter")
                        Divider()
                        Slider(value: $arController.height, in: (0.1)...(2.0))
                        Text("Height")
                    }
                }
                
                Spacer()
            }
        }
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
