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
            unlockFragmentID: "contrail",
            imageName: "item_paper_plane",
            placement: .paperPlane,
            equippedMessage: "白い線の先を、まだ見てる"
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
