//
//  SparkleEffect.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/17.
//

import SwiftUI

extension Color {
    static let sparkleWhite = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let sparkleCyan  = Color(hex: "#E0FFFF")
    static let sparklePink  = Color(hex: "#FFE6FA")
}

// MARK: - 1粒のキラキラ情報
struct SparkleParticle: Identifiable {
    let id = UUID()
    var angle: Double
    var distance: CGFloat
    var opacity: Double
    var scale: CGFloat
    var color: Color
}

// MARK: - 花火キラキラエフェクト
struct SparkleEffect: View {
    @State private var particles: [SparkleParticle] = []
    var trigger: Bool
    var color: Color = .white
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Image(systemName: "sparkle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10 * p.scale, height: 10 * p.scale)
                        .foregroundColor(p.color) // ✅ 発色はそのまま
                        .shadow(color: p.color.opacity(0.8), radius: 6) // ✅ 常に光をまとう
                        .rotationEffect(.degrees(p.angle * 180 / .pi))
                        .position(
                            x: geo.size.width / 2 + cos(p.angle) * p.distance,
                            y: geo.size.height / 2 + sin(p.angle) * p.distance
                        )
                        .opacity(p.opacity)
                }
            }
            .onAppear {
                emitSparkles()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func emitSparkles() {
        let count = 24 // ✨ 少し増やして密度アップ
        let colors: [Color] = [
            Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"),
            Color(hex: "#F8F8FF"),
            Color(hex: "#FFE6FA"),
            Color(hex: "#E0FFFF")
        ]
        
        // 🌟 初期配置（中心に集まる）
        particles = (0..<count).map { i in
            SparkleParticle(
                angle: Double(i) * (2 * .pi / Double(count)),
                distance: 0,
                opacity: 1.0,
                scale: CGFloat.random(in: 0.6...1.4),
                color: colors.randomElement()!
            )
        }
        
        // 💥 外へ弾ける動き
        withAnimation(.easeOut(duration: 1.3)) {
            for i in 0..<particles.count {
                particles[i].distance = CGFloat.random(in: 40...120) // 距離を少し広げて自然に
                particles[i].scale *= 1.4
            }
        }

        // 🌙 少し遅らせてフェードアウト
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 1.0)) {
                for i in 0..<particles.count {
                    particles[i].opacity = 0.0
                }
            }
        }
    }
}
