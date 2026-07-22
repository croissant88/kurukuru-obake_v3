//
//  HomeView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct HomeView: View {
    var onStart: () -> Void

    @AppStorage(PlayerRecords.totalGhostsKey) private var totalGhosts = 0
    @AppStorage(PlayerRecords.totalStarsKey) private var totalStars = 0

    /// STARTボタンの赤（ロゴ赤より少し柔らかい）
    private let logoRed = Color(hex: "e25079")

    var body: some View {
        ZStack {
            GameBackgrounds.starry.ignoresSafeArea()

            VStack(spacing: 12) {
                // プレイ画面と同じ位置・サイズ
                Image("kurukuruobake_01")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 40)
                    .padding(.bottom, 8)

                VStack(spacing: 10) {
                    homeStatRow(title: "解放した魂", value: totalGhosts)
                    homeStatRow(title: "散った星屑", value: totalStars)
                }
                .padding(.top, 16)
                .padding(.horizontal, 36)

                Spacer(minLength: 24)

                Button(action: onStart) {
                    Text("START")
                        .font(.system(size: 24, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: 220)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(logoRed)
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    private func homeStatRow(title: String, value: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
            Spacer()
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: 260)
    }
}
