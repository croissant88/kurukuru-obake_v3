//
//  SoundManager.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/15.
//

import AVFoundation
import SwiftUI
import Combine

final class SoundManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    static let shared = SoundManager()

    /// 既定の BGM（`KurukuruObake` フォルダに置く。同期グループなら自動でバンドルに入る）
    static let defaultBGMFileName = "Rain.aac"

    private static let bgmEnabledKey = "bgmEnabled"
    private static let seEnabledKey = "seEnabled"
    private let defaultBGMVolume: Float = 0.4

    @Published var isBGMEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBGMEnabled, forKey: Self.bgmEnabledKey)
            applyBGMEnabledState()
        }
    }

    @Published var isSEEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSEEnabled, forKey: Self.seEnabledKey)
        }
    }

    private var bgmPlayer: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []
    private var preferredBGMName = SoundManager.defaultBGMFileName

    private override init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.bgmEnabledKey) == nil {
            defaults.set(true, forKey: Self.bgmEnabledKey)
        }
        if defaults.object(forKey: Self.seEnabledKey) == nil {
            defaults.set(true, forKey: Self.seEnabledKey)
        }
        isBGMEnabled = defaults.bool(forKey: Self.bgmEnabledKey)
        isSEEnabled = defaults.bool(forKey: Self.seEnabledKey)
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    // 🎵 BGM 再生（ループ）
    /// `name` は `"Rain.aac"` のように拡張子付き、または従来どおり拡張子なしのリソース名
    /// `-1` = 無限ループ（`AVAudioPlayer` の仕様）
    func playBGM(named name: String = SoundManager.defaultBGMFileName, volume: Float = 0.4) {
        preferredBGMName = name
        if bgmPlayer?.isPlaying == true { return }
        if let player = bgmPlayer {
            player.volume = volume
            if isBGMEnabled, !player.isPlaying {
                player.play()
            }
            return
        }

        guard let url = Self.bundleURL(forFileName: name) else {
            print("BGM ファイル見つからない: \(name)")
            return
        }

        // 大きい音源でもUIを止めないよう、ファイル準備だけバックグラウンドで行う
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = volume
                player.prepareToPlay()
                DispatchQueue.main.async {
                    if self.bgmPlayer != nil { return }
                    do {
                        try self.configureSessionForBGM()
                    } catch {
                        print("BGM セッションエラー: \(error)")
                    }
                    player.delegate = self
                    self.bgmPlayer = player
                    if self.isBGMEnabled {
                        player.play()
                    }
                }
            } catch {
                print("BGM 再生エラー: \(error)")
            }
        }
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        switch type {
        case .ended:
            guard isBGMEnabled else { return }
            try? configureSessionForBGM()
            if let p = bgmPlayer, !p.isPlaying {
                p.play()
            }
        case .began:
            break
        @unknown default:
            break
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === bgmPlayer {
            guard isBGMEnabled else { return }
            // `numberOfLoops == -1` では通常呼ばれないが、念のため先頭から繰り返す
            player.currentTime = 0
            player.numberOfLoops = -1
            player.play()
        } else {
            effectPlayers.removeAll { $0 === player }
        }
    }

    private func configureSessionForBGM() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }

    /// `"Rain.mp3"` → base `Rain` / ext `mp3`
    private static func bundleURL(forFileName name: String) -> URL? {
        if let dot = name.lastIndex(of: "."), dot < name.endIndex {
            let base = String(name[..<dot])
            let ext = String(name[name.index(after: dot)...])
            if let url = Bundle.main.url(forResource: base, withExtension: ext) {
                return url
            }
        }
        return Bundle.main.url(forResource: name, withExtension: nil)
    }

    // 🔇 BGM 停止
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    private func applyBGMEnabledState() {
        if isBGMEnabled {
            if let player = bgmPlayer {
                player.volume = defaultBGMVolume
                if !player.isPlaying {
                    player.play()
                }
            } else {
                playBGM(named: preferredBGMName, volume: defaultBGMVolume)
            }
        } else {
            bgmPlayer?.pause()
        }
    }

    // 🔊 効果音再生（同時再生可）
    func playEffect(named name: String, volume: Float = 1.0) {
        guard isSEEnabled else { return }
        guard let url = Self.bundleURL(forFileName: name) else {
            print("効果音見つからない: \(name)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = volume
            player.prepareToPlay()
            effectPlayers.append(player)
            player.play()
        } catch {
            print("効果音再生エラー: \(error)")
        }
    }
}
