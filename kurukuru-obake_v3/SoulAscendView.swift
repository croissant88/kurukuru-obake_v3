//
//  SoulAscendView.swift
//  kurukuru-obake_v3
//

import SwiftUI

/// Mission Clear カード表示中：タイル消滅と同じスパークル（1セット×2）
struct SoulAscendView: View {
    private struct BurstSpot {
        let x: CGFloat
        let y: CGFloat
        let delay: Double
        let size: CGFloat
    }

    private struct LiveBurst: Identifiable {
        let id: UUID
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }

    private let spots: [BurstSpot] = [
        .init(x: 0.50, y: 0.42, delay: 0.00, size: 160),
        .init(x: 0.22, y: 0.32, delay: 0.45, size: 120),
        .init(x: 0.78, y: 0.34, delay: 0.90, size: 120),
        .init(x: 0.30, y: 0.62, delay: 1.35, size: 110),
        .init(x: 0.70, y: 0.60, delay: 1.80, size: 110),
        .init(x: 0.50, y: 0.22, delay: 2.25, size: 130),
        .init(x: 0.50, y: 0.72, delay: 2.70, size: 100)
    ]

    private let step: Double = 0.45
    private let burstLifetime: Double = 1.6

    @State private var liveBursts: [LiveBurst] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(liveBursts) { burst in
                    SparkleEffect(trigger: true)
                        .frame(width: burst.size, height: burst.size)
                        .position(
                            x: geo.size.width * burst.x,
                            y: geo.size.height * burst.y
                        )
                }
            }
            .onAppear { play() }
        }
        .allowsHitTesting(false)
    }

    private func play() {
        // 同じセットを2回、同じ間隔のまま連続で出す（セット間の休みなし）
        let setLength = Double(spots.count) * step
        for cycle in 0..<2 {
            let base = Double(cycle) * setLength
            for spot in spots {
                let fireAt = base + spot.delay
                DispatchQueue.main.asyncAfter(deadline: .now() + fireAt) {
                    let burst = LiveBurst(
                        id: UUID(),
                        x: spot.x,
                        y: spot.y,
                        size: spot.size
                    )
                    liveBursts.append(burst)
                    DispatchQueue.main.asyncAfter(deadline: .now() + burstLifetime) {
                        liveBursts.removeAll { $0.id == burst.id }
                    }
                }
            }
        }
    }
}
