//
//  RootView.swift
//  kurukuru-obake_v3
//

import SwiftUI

private enum AppScreen {
    case home
    case play
}

struct RootView: View {
    @State private var screen: AppScreen = .home
    @State private var playSessionID = UUID()

    var body: some View {
        ZStack {
            switch screen {
            case .home:
                HomeView {
                    playSessionID = UUID()
                    screen = .play
                }

            case .play:
                ContentView(onGoHome: {
                    screen = .home
                })
                .id(playSessionID)
            }
        }
    }
}
