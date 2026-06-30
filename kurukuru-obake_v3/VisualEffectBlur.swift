//
//  VisualEffectBlur.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/17.
//

import SwiftUI
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // 特に更新処理はいらない
    }
}
