//
//  ChooseUsernameView.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import SwiftUI
import Combine

extension String: Identifiable {
    public var id: String {
        return self
    }
}

extension GeometryProxy {
    fileprivate func rightX(t: CGFloat) -> CGFloat {(x/2 + y/12) + t*((x - y/12) - (x/2 + y/12))}
    fileprivate func leftX(t: CGFloat) -> CGFloat {(x/2 - y/12) + t*(y/12 - (x/2 - y/12))}
}

struct LoggingInView: View {
    
    @ObservedObject var loggingInData: LoggingInData
    
    @State var t: CGFloat = 0.0
    @State var keyboardShowing = false
    
    var body: some View {
        GeometryReader {(proxy: GeometryProxy) in
            ZStack {
                VStack {
                    VStack {
                        Text("Welcome to...")
                            .font(.title)
                        HStack {
                            Text("BUMPER")
                                .font(.largeTitle)
                                .foregroundColor(Color("BlueBallIn"))
                            Text("BALLS")
                                .font(.largeTitle)
                                .foregroundColor(Color("RedBallIn"))
                        }
                        Divider()
                        VStack {
                            TextField("Username", text: $loggingInData.username)
                                .padding()
                                .roundedRectangleEffectDefault()
                                .padding()
                                .frame(width: proxy.x/2, height: proxy.y/12)
                            if loggingInData.state == .submittingUsername {
                            Text("Log In")
                                .roundedRectangleButton(action: loggingInData.attemptLogin)
                                .frame(width: proxy.x/2, height: proxy.y/16)
                                .padding()
                            } else {
                                Text("Processing")
                                    .foregroundColor(Color("Primary"))
                                    .roundedRectangleEffectDefault()
                                    .frame(width: proxy.x/2, height: proxy.y/16)
                                    .padding()
                            }
                        }
                        .padding()
                        Divider()
                    }
                    .frame(height: proxy.y*(2/3))
                    Spacer()
                }
                if !keyboardShowing {
                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [Color("BlueBallIn"),Color("BlueBallOut")]), center: .center, startRadius: 0, endRadius: proxy.y/12)
                        )
                        .framed(width: proxy.y/6, height: proxy.y/6,
                                x: proxy.leftX(t: t), y: proxy.y*(5/6))
                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [Color("RedBallIn"),Color("RedBallOut")]), center: .center, startRadius: 0, endRadius: proxy.y/12)
                        )
                        .framed(width: proxy.y/6, height: proxy.y/6,
                                x: proxy.rightX(t: t), y: proxy.y*(5/6))
                }
            }
        }
        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                t = 1.0
            }
        }
        .onReceive(Publishers.keyboardShowing, perform: {showing in
            if showing {
                keyboardShowing = true
            } else {
                keyboardShowing = false
                t = 0.0
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    t = 1.0
                }
            }
        })
        .alert(item: $loggingInData.errorMessage, content: {(errorMessage: String) in
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        })
    }
}
