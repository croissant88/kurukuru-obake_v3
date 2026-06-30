//
//  Utils.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/17.
//

import Foundation
import SwiftUI

// MARK: - 安全な範囲クランプ
extension Comparable {
    // 💡 ここに「public」を追加します
    public func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
