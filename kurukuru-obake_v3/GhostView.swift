//
//  GhostView.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/30.
//

import SwiftUI

/// 👻 消えたゴーストがふわっと上昇して消えるアニメーション
struct GhostView: View {
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var onDisappear: (() -> Void)? = nil

    var body: some View {
        Image("ghost") // ← あなたの用意した画像名に変更！
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .opacity(opacity)
            .offset(y: yOffset)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 1.4)) {
                    yOffset = -200
                    opacity = 0.0
                    scale = 1.15
                }

                // アニメ終了後に削除
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onDisappear?()
                }
            }
    }
}
