//
//  PlaySettingsMenuView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct PlaySettingsMenuView: View {
    @ObservedObject var sound = SoundManager.shared
    var onHome: () -> Void
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 22) {
                HStack(spacing: 28) {
                    toggleColumn(title: "BGM", isOn: $sound.isBGMEnabled)
                    toggleColumn(title: "SE", isOn: $sound.isSEEnabled)
                }

                Button(action: onHome) {
                    Text("Home")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: "4a9fe8"))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 26)
            .frame(width: 280)
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
