//
//  YukionnaIntroCardView.swift
//  kurukuru-obake_v3
//

import SwiftUI

/// 1プレイ初回だけ：ガラスカードが左→中央→右へ sweep する雪女紹介
struct YukionnaIntroCardView: View {
    @State private var offsetX: CGFloat = 0
    @State private var didStart = false

    private let cardWidth: CGFloat = 196
    private let enterDuration: TimeInterval = 0.55
    private let holdDuration: TimeInterval = 1.05
    private let exitDuration: TimeInterval = 0.45

    var body: some View {
        GeometryReader { geo in
            let travel = geo.size.width * 0.5 + cardWidth

            ZStack {
                Color.black.opacity(0.28)
                    .ignoresSafeArea()

                SpiritGlassCard(
                    imageName: "yukionna",
                    title: "雪女",
                    message: "凍てついた夜……\n君のそばで眠りたい",
                    cardWidth: cardWidth
                )
                .offset(x: offsetX)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
            }
            .onAppear {
                guard !didStart else { return }
                didStart = true
                offsetX = -travel

                withAnimation(.easeOut(duration: enterDuration)) {
                    offsetX = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + enterDuration + holdDuration) {
                    withAnimation(.easeIn(duration: exitDuration)) {
                        offsetX = travel
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
