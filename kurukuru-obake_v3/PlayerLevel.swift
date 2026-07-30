//
//  PlayerLevel.swift
//  kurukuru-obake_v3
//

import Foundation

/// 累計で解放した魂の数に応じた成長
enum PlayerLevel {
    /// 各レベルに必要な累計魂数（インデックス0 = Lv1）
    private static let thresholds: [Int] = [
        0,    // Lv1
        20,   // Lv2
        50,   // Lv3
        100,  // Lv4
        180,  // Lv5
        300,  // Lv6
        450,  // Lv7
        650,  // Lv8
        900,  // Lv9
        1200  // Lv10
    ]

    private static let titles: [String] = [
        "夜歩き見習い",
        "星くず拾い",
        "魂の案内人",
        "夜のともしび",
        "迷い子の守り手",
        "月下の語り部",
        "深宵の案内人",
        "魂の灯台守",
        "永久の道連れ",
        "くるくるの主"
    ]

    static func level(forTotalGhosts total: Int) -> Int {
        var level = 1
        for (index, need) in thresholds.enumerated() where total >= need {
            level = index + 1
        }
        return level
    }

    static func title(forTotalGhosts total: Int) -> String {
        let lv = level(forTotalGhosts: total)
        let index = min(lv - 1, titles.count - 1)
        return titles[index]
    }

    /// 次のレベルに必要な累計魂（最大レベルなら nil）
    static func nextThreshold(forTotalGhosts total: Int) -> Int? {
        let lv = level(forTotalGhosts: total)
        guard lv < thresholds.count else { return nil }
        return thresholds[lv]
    }
}
