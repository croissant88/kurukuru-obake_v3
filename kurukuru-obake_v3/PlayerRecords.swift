//
//  PlayerRecords.swift
//  kurukuru-obake_v3
//

import Foundation

enum PlayerRecords {
    static let totalGhostsKey = "totalUnlockedGhosts"
    static let totalStarsKey = "totalCollectedStars"

    static var totalGhosts: Int {
        UserDefaults.standard.integer(forKey: totalGhostsKey)
    }

    static var totalStars: Int {
        UserDefaults.standard.integer(forKey: totalStarsKey)
    }

    static func addGhosts(_ count: Int) {
        guard count > 0 else { return }
        UserDefaults.standard.set(totalGhosts + count, forKey: totalGhostsKey)
    }

    static func addStars(_ count: Int) {
        guard count > 0 else { return }
        UserDefaults.standard.set(totalStars + count, forKey: totalStarsKey)
    }
}
