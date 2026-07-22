//
//  HomeView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct HomeView: View {
    var onStart: () -> Void

    @AppStorage(PlayerRecords.totalGhostsKey) private var totalGhosts = 0
    @AppStorage(PlayerRecords.totalStarsKey) private var totalStars = 0

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
                .padding(.top, 28)
                .padding(.horizontal, 36)

                // 統計〜START のあいだの中央にカード
                ZStack {
                    SpiritGlassCard(
                        imageName: "ghost_01",
                        title: "無名の魂",
                        message: "ぼくのこと思い出して",
                        imageSize: 96,
                        cardWidth: 180
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Button(action: onStart) {
                    Text("START")
                        .font(.system(size: 24, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: 220)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "6b7fd7"),
                                            Color(hex: "8b6bb8")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(hex: "a8addc"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            SoundManager.shared.playBGM()
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
