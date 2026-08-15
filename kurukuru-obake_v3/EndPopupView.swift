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

    var body: some View {
        ZStack {
            // 🌫 背景暗転
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Clear 時だけカードまわりにスパークル
            if isClear {
                SoulAscendView()
                    .zIndex(1)
            }

            // 🪟 ポップアップ本体
            ZStack(alignment: .topTrailing) {

                VStack(spacing: 18) {

                    Text(isClear ? "クリア" : "ゲームオーバー")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(
                            isClear
                            ? .orange
                            : Color(hex: "598cd2")
                        )
                        .padding(.top, 24)

                    // 🖼 イラスト
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

                    // 🔘 ボタン
                    HStack(spacing: 20) {
                        Button(action: onNewGame) {
                            Text(isClear ? clearActionTitle : "リトライ")
                                .font(.headline)
                                .padding()
                                .frame(width: 120)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: onClose) {
                            Text("ホームへ")
                                .font(.headline)
                                .padding()
                                .frame(width: 120)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: 320)
                .background(Color.white.opacity(0.96))
                .cornerRadius(28)

                // ❌ 閉じる（Clear 時の挙動は ContentView 側で制御）
                Button(action: onClosePopup) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.25))
                        .clipShape(Circle())
                        .padding(12)
                }
            }
            .zIndex(2)
        }
    }

    private func popupRow(icon: String, title: String, value: String, iconTint: Color = Color(hex: "598cd2")) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconTint)
                    .frame(width: 22, alignment: .center)
                Text(title)
                    .foregroundStyle(Color.black.opacity(0.78))
            }
            Spacer()
            Text(value)
                .foregroundStyle(Color.black.opacity(0.92))
        }
        .font(.system(size: 16, weight: .medium))
    }
}
