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
    /// Clear 時に残りうる記憶のカケラ（その夜のストーリーと一致）
    let rewardFragmentID: String?

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
        rewardFriend: .yukionna,
        rewardFragmentID: "bus_stop_summer"
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
            rewardFriend: nil,
            rewardFragmentID: nil
        ),
        Mission(
            id: "normal_rooftop_whisper",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "屋根の上のささやき",
            body: "誰かの家の屋根で、小さな気配がうずくまっている。見つけて、夜道へ還してあげて。",
            ghostTarget: 22,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "rooftop_fence"
        ),
        Mission(
            id: "normal_old_school_hall",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "旧校舎の廊下",
            body: "誰も使わなくなった旧校舎の廊下に、迷い子の気配が残っている。朝が来る前に、解放してあげてほしい。",
            ghostTarget: 28,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "old_school"
        ),
        Mission(
            id: "normal_station_afterglow",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "駅のホームの残り香",
            body: "終電のあとのホームに、置き去りの気配が残っている。朝が来る前に、解放して。",
            ghostTarget: 24,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "last_train_gate"
        ),
        Mission(
            id: "normal_park_slide",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "公園のすべり台",
            body: "誰もいない公園のすべり台に、笑い声だけが残っている。魂を集めて、静かな夜に戻して。",
            ghostTarget: 20,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "park_slide"
        ),
        Mission(
            id: "normal_rainy_vending",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "雨の自動販売機",
            body: "雨音のなか、自販機の灯りだけが白い。そのまわりを、小さな気配がうろうろしている。",
            ghostTarget: 23,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "rainy_vending"
        ),
        Mission(
            id: "normal_laundry_night",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "夜の物干し",
            body: "取りこみ忘れた洗濯物が、風にゆれている。間を抜けて、迷い子が隠れている気配がする。",
            ghostTarget: 21,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "laundry_rope"
        ),
        Mission(
            id: "normal_convenience_back",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "コンビニの裏",
            body: "明かりの届かない裏側に、冷たい気配がたまっている。朝の配達が来る前に、還してあげて。",
            ghostTarget: 25,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "convenience_outside"
        ),
        Mission(
            id: "normal_bridge_fog",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "川霧の橋",
            body: "橋の真ん中だけ、霧が厚い。向こう岸へ行けずにいる魂がいるから、手を貸してほしい。",
            ghostTarget: 27,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "bridge_rail"
        ),
        Mission(
            id: "normal_closed_festival",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "終わった縁日",
            body: "提灯は消えて、屋台の跡だけが残っている。祭りの残り香に、還りきれない魂がいる。",
            ghostTarget: 24,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "festival_goldfish"
        ),
        Mission(
            id: "normal_contrail_sky",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "夏の飛行機雲",
            body: "空の白い線を指さして追っかけた日。あの時の気配がまだ夜に残っている。消えちゃう前に、魂を還してあげて。",
            ghostTarget: 22,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "contrail"
        ),
        Mission(
            id: "normal_paper_plane_street",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "通学路の紙飛行機",
            body: "その家の前を通ると、いつも紙飛行機が飛んでくる。カーテンの向こうの迷い子を、還してあげて。",
            ghostTarget: 21,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "paper_plane"
        ),
        Mission(
            id: "normal_straw_hat_wind",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "風の麦わら帽子",
            body: "突然風が吹いて、帽子だけ先に行ってしまった。あの日の空を思い出す。追いかけて散った魂を、集めてあげて。",
            ghostTarget: 23,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "straw_hat"
        ),
        Mission(
            id: "normal_bug_cage_summer",
            kind: .normal,
            headline: "今夜の頼まれごと",
            shortTitle: "夏休みの虫かご",
            body: "蓋を開けたら何もいなかった縁側に、夏の気配だけが残っている。草のくずのあいだの魂を、還してあげて。",
            ghostTarget: 20,
            moveLimit: 23,
            rewardFriend: nil,
            rewardFragmentID: "bug_cage"
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
