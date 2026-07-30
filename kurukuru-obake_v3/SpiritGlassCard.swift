//
//  SpiritGlassCard.swift
//  kurukuru-obake_v3
//

import SwiftUI

/// 雪女紹介などと同じ系統のガラスカード
struct SpiritGlassCard: View {
    var imageName: String
    var title: String
    var message: String
    /// タイトル上の小見出し（任意）
    var subtitle: String? = nil
    var imageSize: CGFloat = 120
    var cardWidth: CGFloat = 196
    /// Homeなど：指でポケモンカード風に傾けられる
    var allowsTilt: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @State private var tiltX: Double = 0
    @State private var tiltY: Double = 0

    private let maxTilt: Double = 16

    var body: some View {
        GeometryReader { geo in
            cardBody(size: geo.size)
                .rotation3DEffect(
                    .degrees(tiltX),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.55
                )
                .rotation3DEffect(
                    .degrees(tiltY),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.55
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .gesture(allowsTilt ? tiltGesture(in: geo.size) : nil)
        }
        .frame(width: cardWidth)
        .frame(height: estimatedHeight)
    }

    private var estimatedHeight: CGFloat {
        // 画像＋余白＋文字のおおよその高さ（レイアウト用）
        imageSize + 140 + (subtitle == nil ? 0 : 22)
    }

    private func cardBody(size: CGSize) -> some View {
        VStack(spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)

            VStack(spacing: 6) {
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(subtitleColor)
                }

                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(titleColor)
            }

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(subtitleColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 32)
        .frame(width: size.width, height: size.height)
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
                .overlay {
                    if allowsTilt {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.30),
                                        .clear,
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: UnitPoint(
                                        x: 0.35 - tiltY / maxTilt * 0.25,
                                        y: 0.15 + tiltX / maxTilt * 0.15
                                    ),
                                    endPoint: UnitPoint(
                                        x: 0.75 + tiltY / maxTilt * 0.2,
                                        y: 0.95
                                    )
                                )
                            )
                            .blendMode(.screen)
                            .allowsHitTesting(false)
                    }
                }
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func tiltGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let dx = value.location.x - size.width * 0.5
                let dy = value.location.y - size.height * 0.5
                let nextY = Double(dx / max(size.width, 1)) * maxTilt * 2
                let nextX = Double(-dy / max(size.height, 1)) * maxTilt * 2
                tiltY = min(max(nextY, -maxTilt), maxTilt)
                tiltX = min(max(nextX, -maxTilt), maxTilt)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    tiltX = 0
                    tiltY = 0
                }
            }
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
