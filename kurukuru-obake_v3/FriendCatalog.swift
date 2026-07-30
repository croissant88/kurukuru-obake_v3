//
//  FriendCatalog.swift
//  kurukuru-obake_v3
//

import Foundation

enum FriendID: String, CaseIterable, Codable {
    case yukionna

    var displayName: String {
        switch self {
        case .yukionna: return "雪女"
        }
    }

    var imageName: String {
        switch self {
        case .yukionna: return "yukionna"
        }
    }

    /// 訪問カードの小見出し
    var visitSubtitle: String {
        switch self {
        case .yukionna: return "凍てつく夜"
        }
    }

    /// 訪問カードの本文
    var visitMessage: String {
        switch self {
        case .yukionna: return "置いていかないで\nまだ ここにいて"
        }
    }

    /// Clear 後カードの見出し
    var clearHeadline: String {
        switch self {
        case .yukionna: return "新しいお友だち"
        }
    }

    /// Clear 後カードの本文
    var message: String {
        switch self {
        case .yukionna: return "凍てつく夜はあなたと一緒にいたい"
        }
    }
}

enum FriendRecords {
    private static let befriendedKey = "befriendedFriendIDs"

    static var befriendedIDs: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: befriendedKey) ?? [])
    }

    static func isBefriended(_ id: FriendID) -> Bool {
        befriendedIDs.contains(id.rawValue)
    }

    /// 新規ゲットなら true
    @discardableResult
    static func befriend(_ id: FriendID) -> Bool {
        var ids = befriendedIDs
        guard !ids.contains(id.rawValue) else { return false }
        ids.insert(id.rawValue)
        UserDefaults.standard.set(Array(ids), forKey: befriendedKey)
        return true
    }

    /// テスト用：おともだち解放状況を消す
    static func resetAllFriends() {
        UserDefaults.standard.removeObject(forKey: befriendedKey)
    }
}
