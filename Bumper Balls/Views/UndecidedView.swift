//
//  UndecidedView.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/25/21.
//

import SwiftUI
import UIKit

struct UndecidedView: View {
    
    @ObservedObject var undecidedData: UndecidedData
    
    var body: some View {
        GeometryReader {(proxy: GeometryProxy) in
            ZStack {
                VStack {
                    // title bar
                    VStack {
                        HStack  {
                            Spacer()
                            Text("Active Bumper Ball Games")
                                .font(.title2)
                                .foregroundColor(Color("Primary"))
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .roundedRectangleButton(action: undecidedData.reloadTenJoinable)
                                .frame(width: proxy.y/12, height: proxy.y/12, alignment: .center)
                        }
                        .padding()
                        
                        // list of games to join with option to refresh
                        List(undecidedData.tenJoinable) {(id: String) in
                            HStack {
                                Text(verbatim: id)
                                Spacer()
                                Text("Join")
                                    .foregroundColor(Color("Primary"))
                                    .roundedRectangleButton(action: {
                                        undecidedData.joinGame(id: id)
                                    })
                            }
                        }
                        .padding()
                    }
                    .roundedRectangleEffectDefault()
                    .frame(height: proxy.y*(3/4))
                    
                    Spacer()
                    
                    // option to host a game
                    Text(verbatim: "Host Game")
                        .font(.largeTitle)
                        .foregroundColor(Color("Primary"))
                        .roundedRectangleButton(color: Color.red, action: undecidedData.startOfferingToHost)
                        .padding()
                        .frame(width: proxy.x*(2/3), height: proxy.y*(1/6))
                }
                .disabled(undecidedData.offeringToHost)
                if undecidedData.offeringToHost {
                    BlurView()
                    VStack {
                        Text("Waiting for Opponent")
                            .font(.title2)
                            .foregroundColor(Color("Primary"))
                        Text("Cancel")
                            .foregroundColor(Color("Primary"))
                            .roundedRectangleButton(action: undecidedData.stopOfferingToHost)
                            .frame(height: proxy.y*(1/16))
                    }
                    .padding()
                    .roundedRectangleEffectDefault()
                    .frame(width: proxy.x*(2/3), height: proxy.y*(1/4))
                }
            }
        }
        .alert(item: $undecidedData.errorMessage, content: {(errorMessage: String) in
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        })
    }
}
