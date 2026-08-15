//
//  SoulItemCatalog.swift
//  kurukuru-obake_v3
//

import Foundation

struct SoulItem: Identifiable, Equatable {
    let id: String
    /// 表示名
    let name: String
    /// このカケラを持っていると使える
    let unlockFragmentID: String
    /// カード上の SF Symbol（画像アセットが来るまでの仮）
    let symbolName: String
    /// 装備中の無名の魂のセリフ
    let equippedMessage: String
}

enum SoulItemCatalog {
    static let all: [SoulItem] = [
        SoulItem(
            id: "straw_hat",
            name: "麦わら帽子",
            unlockFragmentID: "straw_hat",
            symbolName: "sun.max.fill",
            equippedMessage: "風がまた、帽子を連れていきそう"
        ),
        SoulItem(
            id: "bus_charm",
            name: "バス停の欠片",
            unlockFragmentID: "bus_stop_summer",
            symbolName: "snowflake",
            equippedMessage: "夏なのに、少しだけ冷たい"
        ),
        SoulItem(
            id: "paper_plane",
            name: "紙飛行機",
            unlockFragmentID: "contrail",
            symbolName: "paperplane.fill",
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
