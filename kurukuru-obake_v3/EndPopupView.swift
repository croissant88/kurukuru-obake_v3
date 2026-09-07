import SwiftUI

struct EndPopupView: View {
    var starCount: Int
    var ghosts: Int
    var missionTarget: Int
    var isClear: Bool
    var imageName: String
    var clearActionTitle: String = "次へ"
    var memoryFragmentTitle: String? = nil

    var onNewGame: () -> Void
    var onClose: () -> Void          // Home
    let onClosePopup: () -> Void     // Close（×）

    private let accent = Color(hex: "4a5fb8")
    private let ink = Color(hex: "1d3a5c")

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            if isClear {
                SoulAscendView()
                    .zIndex(1)
            }

            ZStack(alignment: .topTrailing) {
                VStack(spacing: 18) {
                    Text(isClear ? "クリア" : "ゲームオーバー")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(isClear ? Color.orange : accent)
                        .padding(.top, 24)

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)

                    VStack(alignment: .leading, spacing: 12) {
                        popupRow(icon: "star.fill", title: "星屑", value: "\(starCount)")
                        popupRow(icon: "sparkles", title: "解放した魂", value: "\(ghosts) / \(missionTarget)")
                        if let memoryFragmentTitle {
                            popupRow(
                                icon: "moon.stars.fill",
                                title: "記憶のカケラ",
                                value: memoryFragmentTitle
                            )
                        }
                    }
                    .padding(.horizontal, 30)

                    HStack(spacing: 14) {
                        Button(action: onNewGame) {
                            Text(isClear ? clearActionTitle : "リトライ")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 120)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(accent)
                                )
                        }
                        .buttonStyle(.plain)

                        Button(action: onClose) {
                            Text("ホームへ")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(ink.opacity(0.9))
                                .frame(width: 120)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.white.opacity(0.55))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 22)
                }
                .frame(width: 320)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.28), lineWidth: 1)
                        )
                )

                Button(action: onClosePopup) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.28))
                        .clipShape(Circle())
                        .padding(12)
                }
                .buttonStyle(.plain)
            }
            .zIndex(2)
        }
    }

    private func popupRow(icon: String, title: String, value: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 22, alignment: .center)
                Text(title)
                    .foregroundStyle(ink.opacity(0.78))
            }
            Spacer()
            Text(value)
                .foregroundStyle(ink.opacity(0.92))
        }
        .font(.system(size: 16, weight: .medium))
    }
}
