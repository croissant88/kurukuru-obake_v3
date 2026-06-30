import SwiftUI

struct EndPopupView: View {
    var score: Int
    var bestScore: Int
    var starCount: Int
    var ghosts: Int
    var missionTarget: Int
    var imageName: String
    var clearActionTitle: String = "Next Stage"

    var onNewGame: () -> Void
    var onClose: () -> Void          // Home
    let onClosePopup: () -> Void     // Close（×）
    private var isClear: Bool { ghosts >= missionTarget }

    var body: some View {
        ZStack {
            // 🌫 背景暗転
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // 🪟 ポップアップ本体
            ZStack(alignment: .topTrailing) {

                VStack(spacing: 18) {

                    Text(isClear ? "Game Clear" : "Game Over")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
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

                    // 📊 スコア表示（絵文字は環境で ? になることがあるため SF Symbols を使用）
                    VStack(alignment: .leading, spacing: 12) {
                        popupRow(icon: "chart.bar.fill", title: "Score", value: "\(score)")
                        popupRow(icon: "trophy.fill", title: "Best", value: "\(bestScore)")
                        popupRow(icon: "star.fill", title: "Stars", value: "\(starCount)")
                        popupRow(icon: "sparkles", title: "Ghosts", value: "\(ghosts)")
                    }
                    .padding(.horizontal, 30)

                    // 🔘 ボタン
                    HStack(spacing: 20) {
                        Button(action: onNewGame) {
                            Text(isClear ? clearActionTitle : "Retry")
                                .font(.headline)
                                .padding()
                                .frame(width: 120)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: onClose) {
                            Text("Home")
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
        .font(.system(size: 16, weight: .medium, design: .rounded))
    }
}
