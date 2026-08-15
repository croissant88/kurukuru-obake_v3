//
//  MissionCatalog.swift
//  kurukuru-obake_v3
//

import Foundation

enum MissionKind: Equatable {
    case normal
    /// 訪問者が絡む特別な頼まれごと
    case visitor(FriendID)
}

struct Mission: Equatable {
    let id: String
    let kind: MissionKind
    /// 例: 今夜の頼まれごと
    let headline: String
    /// 短い見出し（HUD 用）
    let shortTitle: String
    /// 依頼文
    let body: String
    let ghostTarget: Int
    let moveLimit: Int
    /// Clear 時におともだちになる相手（なければ nil）
    let rewardFriend: FriendID?

    static func == (lhs: Mission, rhs: Mission) -> Bool {
        lhs.id == rhs.id
    }
}

enum MissionCatalog {
    private static let lastNormalMissionKey = "lastNormalMissionID"

    /// 雪女：未ゲット時の特別ミッション
    static let yukionnaRequest = Mission(
        id: "yukionna_bus_stop",
        kind: .visitor(.yukionna),
        headline: "今夜の頼まれごと",
        shortTitle: "とある田舎のバス停",
        body: "夏なのに凍るような寒さを感じる。いくつもの魂が彷徨っている気配。誰か助けてあげて。ただし、近くによるとみんな凍えてしまうから気をつけて！",
        ghostTarget: 26,
        moveLimit: 23,
        rewardFriend: .yukionna
    )

    /// 通常ミッション（手書きプール）
    static let normalMissions: [Mission] = [
        Mission(
            id: "normal_lost_lights",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "迷い子の灯り",
            body: "夜空に迷っている魂がいる。手数のうちに、できるだけ多く解放してあげてほしい。",
            ghostTarget: 26,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_rooftop_whisper",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "屋根の上のささやき",
            body: "誰かの家の屋根で、小さな気配がうずくまっている。見つけて、夜道へ還してあげて。",
            ghostTarget: 22,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_old_school_hall",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "旧校舎の廊下",
            body: "誰も使わなくなった旧校舎の廊下に、迷い子の気配が残っている。朝が来る前に、解放してあげてほしい。",
            ghostTarget: 28,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_station_afterglow",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "駅のホームの残り香",
            body: "終電のあとのホームに、置き去りの気配が残っている。朝が来る前に、解放して。",
            ghostTarget: 24,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_park_slide",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "公園のすべり台",
            body: "誰もいない公園のすべり台に、笑い声だけが残っている。魂を集めて、静かな夜に戻して。",
            ghostTarget: 20,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_rainy_vending",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "雨の自動販売機",
            body: "雨音のなか、自販機の灯りだけが白い。そのまわりを、小さな気配がうろうろしている。",
            ghostTarget: 23,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_laundry_night",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "夜の物干し",
            body: "取りこみ忘れた洗濯物が、風にゆれている。間を抜けて、迷い子が隠れている気配がする。",
            ghostTarget: 21,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_convenience_back",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "コンビニの裏",
            body: "明かりの届かない裏側に、冷たい気配がたまっている。朝の配達が来る前に、還してあげて。",
            ghostTarget: 25,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_bridge_fog",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "川霧の橋",
            body: "橋の真ん中だけ、霧が厚い。向こう岸へ行けずにいる魂がいるから、手を貸してほしい。",
            ghostTarget: 27,
            moveLimit: 23,
            rewardFriend: nil
        ),
        Mission(
            id: "normal_closed_festival",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "終わった縁日",
            body: "提灯は消えて、屋台の跡だけが残っている。祭りの残り香に、還りきれない魂がいる。",
            ghostTarget: 24,
            moveLimit: 23,
            rewardFriend: nil
        )
    ]

    /// 未ゲットなら雪女ミッション、済みなら通常プールから1本
    static func missionForCurrentProgress() -> Mission {
        if !FriendRecords.isBefriended(.yukionna) {
            return yukionnaRequest
        }
        return pickNormalMission()
    }

    /// 直近と同じものを避けてランダム（1本しかない場合はそのまま）
    private static func pickNormalMission() -> Mission {
        let lastID = UserDefaults.standard.string(forKey: lastNormalMissionKey)
        let candidates = normalMissions.filter { $0.id != lastID }
        let pool = candidates.isEmpty ? normalMissions : candidates
        let picked = pool.randomElement() ?? normalMissions[0]
        UserDefaults.standard.set(picked.id, forKey: lastNormalMissionKey)
        return picked
    }
}
