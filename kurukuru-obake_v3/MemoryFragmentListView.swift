//
//  MemoryFragmentListView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct MemoryFragmentListView: View {
    var onClose: () -> Void

    @State private var collected: [MemoryFragment] = []

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 16) {
                HStack {
                    Text("記憶のカケラ")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(collected.count) / \(MemoryFragmentRecords.totalCount)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                if collected.isEmpty {
                    Text("まだ、何も残っていない。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 24)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(collected) { fragment in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(fragment.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(fragment.body)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.78))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 360)
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
        .onAppear {
            collected = MemoryFragmentRecords.collectedFragments()
        }
    }
}
