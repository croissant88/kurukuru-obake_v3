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
            id: "paper_plane",
            title: "飛んできた紙飛行機",
            body: "その家の前を通ると、いつも紙飛行機が飛んできた。振り返ると、もう誰もいなくて、カーテンだけが揺れていた。"
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
        ),
        MemoryFragment(
            id: "festival_goldfish",
            title: "縁日の金魚すくい",
            body: "すくうたびに紙が破れて、金魚だけが光って見えた。袋のなかは、もう空だった。"
        ),
        MemoryFragment(
            id: "rainy_vending",
            title: "雨の自販機のまえ",
            body: "コインを入れて、押したボタンは光らないまま。足元に、ぬれたレシートだけが残っていた。"
        ),
        MemoryFragment(
            id: "laundry_rope",
            title: "夜の物干しロープ",
            body: "取りこみ忘れたタオルが、風にぱたぱたしていた。誰かの体温みたいなにおいがした。"
        ),
        MemoryFragment(
            id: "last_train_gate",
            title: "終電あとの改札",
            body: "改札の向こうで、足音がひとつだけ響いた。切符入れに、折れた半券が残っていた。"
        ),
        MemoryFragment(
            id: "rooftop_fence",
            title: "屋上のフェンス",
            body: "空が近すぎて、指をかけたまましばらく動けなかった。錆のにおいと、風だけが強かった。"
        ),
        MemoryFragment(
            id: "convenience_outside",
            title: "コンビニの明かりの外",
            body: "中は白いのに、一歩外へ出ると夜が濃い。レジのレシートが、靴の裏についていた。"
        ),
        MemoryFragment(
            id: "bridge_rail",
            title: "川霧の橋のてすり",
            body: "てすりがぬれて冷たくて、向こう岸が見えなかった。手を離すと、霧だけが残った。"
        ),
        MemoryFragment(
            id: "bug_cage",
            title: "夏休みの虫かご",
            body: "蓋を開けたら、もう何もいなかった。底に、草のくずだけが乾いていた。"
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
