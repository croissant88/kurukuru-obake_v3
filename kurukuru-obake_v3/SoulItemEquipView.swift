//
//  SoulItemEquipView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct SoulItemEquipView: View {
    var onClose: () -> Void
    var onChanged: () -> Void

    private var unlocked: [SoulItem] {
        SoulItemRecords.unlockedItems()
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 16) {
                Text("無名の魂に渡す")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("記憶のカケラから残ったものを、ひとつだけ渡せます。")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 10) {
                    equipRow(
                        title: "なし",
                        symbol: nil,
                        isSelected: SoulItemRecords.equippedID == nil
                    ) {
                        SoulItemRecords.equippedID = nil
                        onChanged()
                    }

                    if unlocked.isEmpty {
                        Text("まだ渡せるものがない。カケラが増えると、ここに出る。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(unlocked) { item in
                            equipRow(
                                title: item.name,
                                symbol: item.symbolName,
                                isSelected: SoulItemRecords.equippedID == item.id
                            ) {
                                SoulItemRecords.equippedID = item.id
                                onChanged()
                            }
                        }
                    }
                }

                Button(action: onClose) {
                    Text("とじる")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: "6b7fd7"))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    private func equipRow(
        title: String,
        symbol: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 28)
                } else {
                    Color.clear.frame(width: 28)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "4bc995"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06))
            )
        }
        .buttonStyle(.plain)
    }
}
