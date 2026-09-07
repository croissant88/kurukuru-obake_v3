//
//  SoulItemCatalog.swift
//  kurukuru-obake_v3
//

import CoreGraphics
import Foundation

/// 無名の魂カード上でのアクセサリ配置（見た目基準・右が正）
struct SoulItemPlacement: Equatable {
    /// 魂画像サイズに対するアクセサリの表示サイズ比
    var sizeRatio: CGFloat
    /// 魂中心からのオフセット（魂サイズ比。+x=右, +y=下）
    var offsetX: CGFloat
    var offsetY: CGFloat
    /// バス停など左隣に置くとき、魂を右へずらす量（魂サイズ比）
    var ghostShiftX: CGFloat

    static let strawHat = SoulItemPlacement(
        sizeRatio: 0.40,
        offsetX: 0.30,
        offsetY: -0.42,
        ghostShiftX: 0
    )

    static let busTimetable = SoulItemPlacement(
        sizeRatio: 0.78,
        offsetX: -0.78,
        offsetY: 0.02,
        ghostShiftX: 0.26
    )

    static let paperPlane = SoulItemPlacement(
        sizeRatio: 0.34,
        offsetX: 0.40,
        offsetY: -0.46,
        ghostShiftX: 0
    )

    /// 飛行機＋雲：左上（上に余白）
    static let contrail = SoulItemPlacement(
        sizeRatio: 0.58,
        offsetX: -0.62,
        offsetY: -0.36,
        ghostShiftX: 0.18
    )

    /// 旧校舎の風：右上（帽子・紙飛行機系）
    static let oldSchool = SoulItemPlacement(
        sizeRatio: 0.38,
        offsetX: 0.50,
        offsetY: -0.44,
        ghostShiftX: 0
    )

    /// 砂場：おばけの左下
    static let parkSlide = SoulItemPlacement(
        sizeRatio: 0.52,
        offsetX: -0.42,
        offsetY: 0.42,
        ghostShiftX: 0.08
    )

    /// 金魚：右手もと
    static let goldfish = SoulItemPlacement(
        sizeRatio: 0.42,
        offsetX: 0.40,
        offsetY: 0.12,
        ghostShiftX: 0
    )

    /// とんぼ：左まわり（虫かごカケラ用）
    static let bugCage = SoulItemPlacement(
        sizeRatio: 0.55,
        offsetX: -0.45,
        offsetY: -0.08,
        ghostShiftX: 0.10
    )

    /// フェンスの欠片：右上（帽子系）
    static let rooftopFence = SoulItemPlacement(
        sizeRatio: 0.36,
        offsetX: 0.42,
        offsetY: -0.40,
        ghostShiftX: 0
    )
}

struct SoulItem: Identifiable, Equatable {
    let id: String
    /// 表示名
    let name: String
    /// このカケラを持っていると使える
    let unlockFragmentID: String
    /// Assets の画像名
    let imageName: String
    /// カード上の配置
    let placement: SoulItemPlacement
    /// 装備中の無名の魂のセリフ
    let equippedMessage: String
}

enum SoulItemCatalog {
    static let all: [SoulItem] = [
        SoulItem(
            id: "straw_hat",
            name: "麦わら帽子",
            unlockFragmentID: "straw_hat",
            imageName: "item_straw_hat",
            placement: .strawHat,
            equippedMessage: "風がまた、帽子を連れていきそう"
        ),
        SoulItem(
            id: "bus_charm",
            name: "バス停の欠片",
            unlockFragmentID: "bus_stop_summer",
            imageName: "item_bus_timetable",
            placement: .busTimetable,
            equippedMessage: "夏なのに、少しだけ冷たい"
        ),
        SoulItem(
            id: "paper_plane",
            name: "紙飛行機",
            unlockFragmentID: "paper_plane",
            imageName: "item_paper_plane",
            placement: .paperPlane,
            equippedMessage: "カーテンの向こうから、また飛んでくる気がする"
        ),
        SoulItem(
            id: "contrail",
            name: "飛行機雲",
            unlockFragmentID: "contrail",
            imageName: "item_contrail",
            placement: .contrail,
            equippedMessage: "白い線の先を、まだ見てる"
        ),
        SoulItem(
            id: "old_school",
            name: "校舎の風",
            unlockFragmentID: "old_school",
            imageName: "item_old_school",
            placement: .oldSchool,
            equippedMessage: "廊下の角で、風だけが通っていく"
        ),
        SoulItem(
            id: "park_slide",
            name: "砂場のおもちゃ",
            unlockFragmentID: "park_slide",
            imageName: "item_park_slide",
            placement: .parkSlide,
            equippedMessage: "座面のあたたかさが、まだ残ってる"
        ),
        SoulItem(
            id: "goldfish",
            name: "縁日の金魚",
            unlockFragmentID: "festival_goldfish",
            imageName: "item_goldfish",
            placement: .goldfish,
            equippedMessage: "光って見えたのに、もういない"
        ),
        SoulItem(
            id: "bug_cage",
            name: "夏のとんぼ",
            unlockFragmentID: "bug_cage",
            imageName: "item_bug_cage",
            placement: .bugCage,
            equippedMessage: "蓋を開けたら、もう何もいなかった"
        ),
        SoulItem(
            id: "rooftop_fence",
            name: "屋上のフェンス",
            unlockFragmentID: "rooftop_fence",
            imageName: "item_rooftop_fence",
            placement: .rooftopFence,
            equippedMessage: "指先に、錆と風が残ってる"
        )
    ]

    static func item(id: String) -> SoulItem? {
        all.first { $0.id == id }
    }
}

enum SoulItemRecords {
    static let equippedKey = "equippedSoulItemID"

    static var equippedID: String? {
        get {
            let raw = UserDefaults.standard.string(forKey: equippedKey)
            guard let raw,
                  let item = SoulItemCatalog.item(id: raw),
                  isUnlocked(item) else {
                return nil
            }
            return raw
        }
        set {
            if let newValue,
               let item = SoulItemCatalog.item(id: newValue),
               isUnlocked(item) {
                UserDefaults.standard.set(newValue, forKey: equippedKey)
            } else {
                UserDefaults.standard.removeObject(forKey: equippedKey)
            }
        }
    }

    static var equipped: SoulItem? {
        guard let id = equippedID else { return nil }
        return SoulItemCatalog.item(id: id)
    }

    static func isUnlocked(_ item: SoulItem) -> Bool {
        MemoryFragmentRecords.isCollected(item.unlockFragmentID)
    }

    static func unlockedItems() -> [SoulItem] {
        SoulItemCatalog.all.filter(isUnlocked)
    }
}
