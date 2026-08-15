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
        ZStack(alignment: .top) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 16) {
                Text("無名の魂に渡す")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "1d3a5c"))

                Text("記憶のカケラから残ったものを、ひとつだけ渡せます。")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "1d3a5c").opacity(0.65))

                VStack(spacing: 10) {
                    if unlocked.isEmpty {
                        Text("まだ渡せるものがない。カケラが増えると、ここに出る。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "1d3a5c").opacity(0.5))
                            .padding(.vertical, 8)
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
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(hex: "1d3a5c").opacity(0.12), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.top, 56)
        }
    }

    private func equipRow(
        title: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "598cd2"))
                    .frame(width: 28, height: 22)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "1d3a5c"))
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "4bc995"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color(hex: "6b7fd7").opacity(0.12) : Color(hex: "1d3a5c").opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}
