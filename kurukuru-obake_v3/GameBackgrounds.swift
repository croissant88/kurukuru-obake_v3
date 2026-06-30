//
//  GameBackgrounds.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/14.
//
//
import SwiftUI

struct GameBackgrounds {
    
    /// ☁️ 朝〜昼の空
    static let sky = AnyView(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#b3e5fc"),
                Color(hex: "#f8f9d2")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    
    /// 🌌 夜空（流れ星付き）
    static let starry = AnyView(
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.1, blue: 0.4),   // 深い夜空の青
                    Color(red: 0.2, green: 0.4, blue: 0.8),   // 夜明け前の青
                    Color(red: 0.6, green: 0.6, blue: 0.9),   // 柔らかい紫青
                    Color(red: 0.95, green: 0.75, blue: 0.85) // 朝焼けピンク
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            ShootingStarView() // 💫 ← これで流れ星を重ねる
        }
    )
}
