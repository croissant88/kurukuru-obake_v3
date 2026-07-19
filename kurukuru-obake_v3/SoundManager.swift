//
//  SoundManager.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/15.
//

import AVFoundation

final class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()

    /// 既定の BGM（`KurukuruObake` フォルダに置く。同期グループなら自動でバンドルに入る）
    static let defaultBGMFileName = "Rain.aac"

    private var bgmPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?

    private override init() {
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
        if bgmPlayer?.isPlaying == true { return }

        guard let url = Self.bundleURL(forFileName: name) else {
            print("BGM ファイル見つからない: \(name)")
            return
        }
        do {
            try configureSessionForBGM()
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            bgmPlayer = player
            player.play()
        } catch {
            print("BGM 再生エラー: \(error)")
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
        // `numberOfLoops == -1` では通常呼ばれないが、念のため先頭から繰り返す
        guard player === bgmPlayer else { return }
        player.currentTime = 0
        player.numberOfLoops = -1
        player.play()
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
    }

    // 🔊 効果音再生（同時再生可）
    func playEffect(named name: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("効果音見つからない: \(name)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            effectPlayer = player // 弱参照を保持して途中で消えないようにする
        } catch {
            print("効果音再生エラー: \(error)")
        }
    }
}
