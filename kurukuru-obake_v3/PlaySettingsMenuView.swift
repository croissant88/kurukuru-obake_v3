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
                HStack(spacing: 20) {
                    toggleColumn(title: "BGM", isOn: $sound.isBGMEnabled)
                    toggleColumn(title: "効果音", isOn: $sound.isSEEnabled)
                }

                VStack(spacing: 8) {
                    Text(mission.headline)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.55))
                    Text(mission.shortTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.92))
                        .multilineTextAlignment(.center)
                    Rectangle()
                        .fill(Color.primary.opacity(0.45))
                        .frame(height: 1)
                    Text(mission.body)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 2)
                    Text("魂 \(mission.ghostTarget) 体　／　\(mission.moveLimit) 手")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.5))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
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
                                .fill(Color(hex: "4a5fb8"))
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
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "1d3a5c").opacity(0.85))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: "4a5fb8"))
        }
        .frame(maxWidth: .infinity)
    }
}
