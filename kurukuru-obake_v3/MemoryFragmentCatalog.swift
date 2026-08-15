//
//  MemoryFragmentCatalog.swift
//  kurukuru-obake_v3
//

import Foundation

struct MemoryFragment: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
}

enum MemoryFragmentCatalog {
    /// 最小セット（あとで足す）
    static let all: [MemoryFragment] = [
        MemoryFragment(
            id: "contrail",
            title: "飛行機雲を追いかけた日",
            body: "空の白い線を指さして、消えちゃう前に追っかけた。息が切れて、笑った。"
        ),
        MemoryFragment(
            id: "straw_hat",
            title: "麦わら帽子が風にさらわれた日",
            body: "風が強くて、帽子だけ先に行ってしまった。追いかけたあと、空がやけに青かった。"
        ),
        MemoryFragment(
            id: "bus_stop_summer",
            title: "夏なのに凍えたバス停",
            body: "待ってるあいだ、息が白くなった。誰かの待ち合わせが、夜に残っていた。"
        ),
        MemoryFragment(
            id: "park_slide",
            title: "誰もいないすべり台",
            body: "笑い声だけが残っていて、座面は少し温かかった。もう誰もいなかった。"
        ),
        MemoryFragment(
            id: "old_school",
            title: "旧校舎の午後",
            body: "使われなくなった廊下に、靴音が残っている気がした。角を曲がると、風だけが通った。"
        )
    ]

    static func fragment(id: String) -> MemoryFragment? {
        all.first { $0.id == id }
    }

    /// 雪女の夜 Clear で優先して残るカケラ
    static let yukionnaClearFragmentID = "bus_stop_summer"
}

enum MemoryFragmentRecords {
    static let collectedKey = "collectedMemoryFragmentIDs"
    /// Home など UI 更新用（collect のたびに増える）
    static let revisionKey = "collectedMemoryFragmentRevision"

    /// UserDefaults に Array / 壊れた String のどちらでも読めるようにする
    private static func loadIDs() -> [String] {
        let defaults = UserDefaults.standard
        if let array = defaults.stringArray(forKey: collectedKey) {
            return array
        }
        // 以前 @AppStorage(String) で壊れた場合の救済
        if let string = defaults.string(forKey: collectedKey), !string.isEmpty {
            let parts = string
                .split(whereSeparator: { ", \n".contains($0) })
                .map(String.init)
                .filter { !$0.isEmpty }
            if !parts.isEmpty {
                saveIDs(parts)
                return parts
            }
        }
        return []
    }

    private static func saveIDs(_ ids: [String]) {
        let unique = Array(Set(ids)).sorted()
        let defaults = UserDefaults.standard
        defaults.set(unique, forKey: collectedKey)
        defaults.set(defaults.integer(forKey: revisionKey) + 1, forKey: revisionKey)
    }

    static var collectedIDs: Set<String> {
        Set(loadIDs())
    }

    static var collectedCount: Int { loadIDs().count }

    static var totalCount: Int { MemoryFragmentCatalog.all.count }

    static func isCollected(_ id: String) -> Bool {
        collectedIDs.contains(id)
    }

    /// 新規なら true
    @discardableResult
    static func collect(_ id: String) -> Bool {
        var ids = loadIDs()
        guard !ids.contains(id) else { return false }
        ids.append(id)
        saveIDs(ids)
        return true
    }

    static func collectedFragments() -> [MemoryFragment] {
        let ids = Set(loadIDs())
        return MemoryFragmentCatalog.all.filter { ids.contains($0.id) }
    }

    static func uncollectedFragments() -> [MemoryFragment] {
        let ids = Set(loadIDs())
        return MemoryFragmentCatalog.all.filter { !ids.contains($0.id) }
    }
}
