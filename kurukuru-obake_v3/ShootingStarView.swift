//
//  ShootingStarView.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/14.
//

import SwiftUI

struct ShootingStarData: Identifiable {
    let id = UUID()
    let delay: Double
    let startX: CGFloat
    let size: CGFloat
}

struct ShootingStar: View {
    @State private var animate = false
    @State private var opacity: Double = 0

    var delay: Double
    var startX: CGFloat
    var size: CGFloat

    var body: some View {
        GeometryReader { geo in
            Image("star")
                .resizable()
                .frame(width: size, height: size)
                .offset(
                    x: animate ? -geo.size.width : startX,
                    y: animate ? geo.size.height : -50
                )
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.1).delay(delay)) {
                        opacity = 0.2
                    }
                    withAnimation(.easeIn(duration: 0.2).delay(delay + 0.1)) {
                        opacity = 1.0
                    }
                    withAnimation(.easeOut(duration: 0.3).delay(delay + 0.3)) {
                        opacity = 0.0
                    }

                    withAnimation(.linear(duration: 1.1).delay(delay)) {
                        animate = true
                    }
                }
        }
    }
}

struct ShootingStarView: View {
    @State private var stars: [ShootingStarData] = []
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            ForEach(stars) { star in
                ShootingStar(
                    delay: star.delay,
                    startX: star.startX,
                    size: star.size
                )
            }
        }
        .onAppear {
            // タイマーで定期的に新しい流れ星を追加
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                let newStar = ShootingStarData(
                    delay: 0,
                    startX: CGFloat.random(in: 50...300),
                    size: CGFloat.random(in: 20...40)
                )
                stars.append(newStar)
                if stars.count > 20 { stars.removeFirst() }
            }
        }
        .onDisappear {
            // ここは View 修飾子。Timer 生成とは別階層に置く
            timer?.invalidate()
            timer = nil
        }
    }

}

