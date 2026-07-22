//
//  YukionnaIntroCardView.swift
//  kurukuru-obake_v3
//

import SwiftUI

/// 1プレイ初回だけ：ガラスカードが左→中央→右へ sweep する雪女紹介
struct YukionnaIntroCardView: View {
    @Environment(\.colorScheme) private var colorScheme
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

                cardContent
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

    private var cardContent: some View {
        VStack(spacing: 14) {
            Image("yukionna")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(color: Color.cyan.opacity(0.35), radius: 8, y: 2)

            Text("雪女")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(titleColor)

            Text("凍てついた夜は君の心が欲しい")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(subtitleColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 32)
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(cardTint)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.42 : 0.72),
                                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.18), radius: 16, y: 8)
        )
    }

    private var cardTint: Color {
        colorScheme == .dark
            ? Color.cyan.opacity(0.10)
            : Color.white.opacity(0.28)
    }

    private var titleColor: Color {
        colorScheme == .dark ? .white : Color(hex: "1d3a5c")
    }

    private var subtitleColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.78)
            : Color(hex: "1d3a5c").opacity(0.72)
    }
}
