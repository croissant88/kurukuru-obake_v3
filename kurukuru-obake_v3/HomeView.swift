//
//  HomeView.swift
//  kurukuru-obake_v3
//

import SwiftUI

struct HomeView: View {
    var onStart: () -> Void

    @AppStorage(PlayerRecords.totalGhostsKey) private var totalGhosts = 0
    @AppStorage(PlayerRecords.totalStarsKey) private var totalStars = 0
    @AppStorage(MemoryFragmentRecords.revisionKey) private var fragmentRevision = 0
    @State private var showMemoryFragments = false
    @State private var showSoulItemEquip = false
    @State private var equippedItem: SoulItem? = SoulItemRecords.equipped

    private var collectedFragmentCount: Int {
        _ = fragmentRevision
        return MemoryFragmentRecords.collectedCount
    }

    private var playerLevel: Int {
        PlayerLevel.level(forTotalGhosts: totalGhosts)
    }

    private var playerTitle: String {
        PlayerLevel.title(forTotalGhosts: totalGhosts)
    }

    private var soulCardMessage: String {
        equippedItem?.equippedMessage ?? "ぼくのこと思い出して"
    }

    private var soulCardSubtitle: String? {
        equippedItem?.name
    }

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
                    .onLongPressGesture(minimumDuration: 0.8) {
                        // TODO: 本番前に削除 — テスト用おともだちリセット
                        FriendRecords.resetAllFriends()
                    }

                VStack(spacing: 6) {
                    Text("Lv.\(playerLevel)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text(playerTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 12)

                VStack(spacing: 10) {
                    homeStatRow(title: "解放した魂", value: totalGhosts)
                    homeStatRow(title: "散った星屑", value: totalStars)
                    Button {
                        showMemoryFragments = true
                    } label: {
                        HStack {
                            Text("記憶のカケラ")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.88))
                            Spacer()
                            Text("\(collectedFragmentCount) / \(MemoryFragmentRecords.totalCount)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 260)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                .padding(.horizontal, 36)

                // 統計〜START のあいだの中央にカード
                VStack(spacing: 10) {
                    SpiritGlassCard(
                        imageName: "ghost_01",
                        title: "無名の魂",
                        message: soulCardMessage,
                        subtitle: soulCardSubtitle,
                        accessoryItem: equippedItem,
                        imageSize: 96,
                        cardWidth: 180,
                        allowsTilt: true
                    )

                    Button {
                        showSoulItemEquip = true
                    } label: {
                        Text("思い出のアイテム")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Button(action: {
                    SoundManager.shared.playEffect(named: "popi.mp3")
                    onStart()
                }) {
                    Text("スタート")
                        .font(.system(size: 24, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: 220)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(hex: "4a5fb8"))
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 36)
            }

            if showMemoryFragments {
                MemoryFragmentListView {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showMemoryFragments = false
                    }
                }
                .transition(.opacity)
                .zIndex(20)
            }

            if showSoulItemEquip {
                SoulItemEquipView(
                    onClose: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSoulItemEquip = false
                        }
                    },
                    onChanged: {
                        equippedItem = SoulItemRecords.equipped
                    }
                )
                .transition(.opacity)
                .zIndex(21)
            }
        }
        .onAppear {
            equippedItem = SoulItemRecords.equipped
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
