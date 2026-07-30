//
//  PlaySettingsMenuView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct PlaySettingsMenuView: View {
    @ObservedObject var sound = SoundManager.shared
    var mission: Mission
    var onHome: () -> Void
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 20) {
                HStack(spacing: 28) {
                    toggleColumn(title: "BGM", isOn: $sound.isBGMEnabled)
                    toggleColumn(title: "SE", isOn: $sound.isSEEnabled)
                }

                VStack(spacing: 8) {
                    Text(mission.headline)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.55))
                    Text(mission.shortTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.92))
                        .multilineTextAlignment(.center)
                    Text(mission.body)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                    Text("魂 \(mission.ghostTarget) 体　／　\(mission.moveLimit) 手")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )

                Button(action: onHome) {
                    Text("ホーム")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(hex: "a8addc"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 26)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
            )
        }
    }

    private func toggleColumn(title: String, isOn: Binding<Bool>) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.9))
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: "4bc995"))
        }
        .frame(maxWidth: .infinity)
    }
}
