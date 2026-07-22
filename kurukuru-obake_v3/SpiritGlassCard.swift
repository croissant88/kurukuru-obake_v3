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
    var imageSize: CGFloat = 120
    var cardWidth: CGFloat = 196

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(titleColor)

            Text(message)
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
