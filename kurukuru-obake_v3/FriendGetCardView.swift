//
//  FriendGetCardView.swift
//  kurukuru-obake_v3
//

import SwiftUI

/// Clear 報酬：おともだちゲット（くるくる登場 → タップで閉じる）
struct FriendGetCardView: View {
    let friend: FriendID
    var onDismiss: () -> Void

    @State private var spinDegrees: Double = 540
    @State private var cardScale: CGFloat = 0.35
    @State private var cardOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var canDismiss = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(friend.clearHeadline)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "ffe7a8"),
                                Color.white,
                                Color(hex: "c9b6ff")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(titleOpacity)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "ffe7a8").opacity(0.55),
                                    Color(hex: "8b6bb8").opacity(0.18),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)
                        .opacity(glowOpacity)
                        .blur(radius: 6)

                    SpiritGlassCard(
                        imageName: friend.imageName,
                        title: friend.displayName,
                        message: friend.message
                    )
                    .rotation3DEffect(
                        .degrees(spinDegrees),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.65
                    )
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                }

                Text("タップしてつづける")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .opacity(canDismiss ? 1 : 0)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard canDismiss else { return }
            onDismiss()
        }
        .onAppear {
            playReveal()
        }
    }

    private func playReveal() {
        withAnimation(.easeOut(duration: 0.25)) {
            titleOpacity = 1
            cardOpacity = 1
        }
        withAnimation(.spring(response: 0.85, dampingFraction: 0.78)) {
            spinDegrees = 0
            cardScale = 1
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
            glowOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.25)) {
                canDismiss = true
            }
        }
    }
}
