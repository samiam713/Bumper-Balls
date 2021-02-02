//
//  ResetWrapper.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/25/21.
//

import SwiftUI
import Combine
import UIKit

extension View {
    func roundedRectangleEffect(color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundColor(color.opacity(0.2))
            RoundedRectangle(cornerRadius: 10.0)
                .stroke()
                .foregroundColor(color)
            self
        }
    }
    
    func roundedRectangleEffectDefault() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundColor(Color("Secondary"))
            RoundedRectangle(cornerRadius: 10.0)
                .stroke()
                .foregroundColor(Color("Primary"))
            self
        }
    }

    func roundedRectangleButton(color: Color = Color.blue, action: @escaping ()->()) -> some View {
        Button(action: action) {
            self
            .roundedRectangleEffect(color: color)
        }
        .buttonStyle(DefaultButtonStyle())
    }
}

extension View {
    func resetWrapper() -> some View {
        GeometryReader {(proxy: GeometryProxy) in
            ZStack {
                self
                Button(action: {appController.abandonOpponent()}) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                    }
                    .foregroundColor(Color("Primary"))
                    .roundedRectangleEffect(color: .blue)
                    .frame(width: proxy.size.width*(1/3), height: proxy.size.width*(3/32), alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: proxy.size.width*(2/9), y: proxy.size.width*(3/32))
            }
        }
    }
}


extension View {
    func framedKeyboardAdaptive(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        modifier(FramedKeyboardAdaptive(width: width, height: height, x: x, y: y))
    }
    func framed(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        return self
            .frame(width: width, height: height, alignment: .center)
            .position(x: x, y: y)
    }
}

struct FramedKeyboardAdaptive: ViewModifier {
    
    let width: CGFloat
    let height: CGFloat
    let x: CGFloat
    let y: CGFloat
    @State var actualY: CGFloat = 0.0
    
    init(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) {
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.actualY = self.y
    }
    
    func body(content: Content) -> some View {
        GeometryReader {(proxy: GeometryProxy) in
            content
                .frame(width: width, height: height, alignment: .center)
                .position(x: x, y: actualY)
                .onReceive(Publishers.keyboardHeight, perform: {(keyBoardHeight: CGFloat) in
                    let globalRect = proxy.frame(in: .global)
                    let calculatedY = height/2 + keyBoardHeight - UIScreen.main.bounds.height + globalRect.maxY
                    if calculatedY < y {
                        actualY = y
                    } else {
                        actualY = calculatedY
                    }
                })
        }
    }
}

extension String {
    func toView() -> some View {
        return Text(verbatim: self)
            .foregroundColor(Color("Primary"))
            .roundedRectangleEffectDefault()
    }
}

struct BlurView: UIViewRepresentable {
    init(effect: UIBlurEffect.Style = .systemUltraThinMaterial){
        self.effect = effect
    }
    let effect: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: effect)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {}
}
