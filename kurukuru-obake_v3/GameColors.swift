//
//  GameColors.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/14.
//
//

import SwiftUI

struct GameColors {
    /// 青・緑はガラス盤向けのまま。赤・黄・紫は従来のタイル色に戻している
    static let red    = Color(hex: "ff8872")
    static let blue   = Color(hex: "4a9fe8")
    static let green  = Color(hex: "4bc995")
    static let yellow = Color(hex: "ffd966")
    static let purple = Color(hex: "c99ed8")
  /*  static let ghost = Color(hex: "cccccc")*/ // 👻 ゴースト専用

    static let all: [Color] = [red, blue, green, yellow, purple]
    // MARK: - ボタンカラー
    static let buttonRed = Color(hex: "f9604b")
    static let buttonBlue = Color(hex: "00a7de")
    
}

// MARK: - Exact RGB (補正なし)
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        // ✅ UIKit経由で表示補正なしのsRGBカラーを生成
        self = Color(UIColor(red: r, green: g, blue: b, alpha: 1.0))
    }
}
// MARK: - Background themes
extension GameColors {
    static let starryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.1, blue: 0.4),   // 深い夜空の青
            Color(red: 0.2, green: 0.4, blue: 0.8),   // 明るい青
            Color(red: 0.6, green: 0.6, blue: 0.9),   // 柔らかい紫青
            Color(red: 0.95, green: 0.75, blue: 0.85) // 朝焼けピンク
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

extension GameColors {
    static func random() -> Color {
        // ゴースト以外の通常カラーからランダムに返す
        return [red, blue, green, yellow, purple].randomElement()!
    }
}

// ステージの種類を定義
enum GameStage: String, CaseIterable {
    case library = "真夜中の図書館"
    case ocean = "夏の終わりの海"
    case crossroad = "雨の交差点"
    
    // ステージごとのメインカラー
    var mainColor: Color {
        switch self {
        case .library: return Color(red: 0.1, green: 0.1, blue: 0.3) // 深い紺
        case .ocean: return Color.blue.opacity(0.6)                // 透き通った青
        case .crossroad: return Color.gray                         // 雨のグレー
        }
    }
}
