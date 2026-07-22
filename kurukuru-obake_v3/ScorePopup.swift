//
//  ScorePopup.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/30.
//

import SwiftUI

struct ScorePopup: View {
    let points: Int
    let position: CGPoint
    
    @State private var rise = false
    @State private var fadeOut = false
    
    var body: some View {
        Text("+\(points)")
            .font(.system(size: 20, weight: .heavy))
            .foregroundColor(.white)
//            .shadow(color: .orange.opacity(0.8), radius: 8, y: 2)
            .opacity(fadeOut ? 0 : 1)
            .offset(y: rise ? -60 : 0)
            .scaleEffect(rise ? 1.2 : 1.0)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    rise = true
                }
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    fadeOut = true
                }
            }
    }
}
