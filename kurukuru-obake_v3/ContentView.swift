import SwiftUI
import Combine

struct ContentView: View {
    private let bestScoreKey = "bestScore"
    private let moveLimit = 23

    var onGoHome: () -> Void = {}

    @StateObject private var board = GameBoard()
    @State private var dragColor: Color? = nil
    @State private var selected: [Coord] = []
    @State private var gameStartTime: Date?
    @State private var displayElapsedSeconds = 0
    @State private var moveCount = 0
    @State private var endPopupImageName = "clear_01"
    /// Game Over ポップアップを × で閉じたあと、盤面は触れないがタップでポップアップを出し直せる
    @State private var endPopupDismissed = false
    @State private var playLockedAfterEnd = false
    @State private var showMissionBriefing = true
    @State private var missionBriefingOpacity: Double = 1.0
    @State private var showSettingsMenu = false
    @State private var showHomeConfirm = false
    private let playTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    private var timeString: String {
        let s = displayElapsedSeconds
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    private var bestScore: Int {
        UserDefaults.standard.integer(forKey: bestScoreKey)
    }

    private var showEndPopup: Bool {
        board.isGameOver && !endPopupDismissed
    }

    private var canInteract: Bool {
        !showMissionBriefing
            && !board.isGameOver
            && !board.isGameOverPending
            && !board.isMissionClearPending
            && !board.isMischiefAnimating
            && !playLockedAfterEnd
            && !showSettingsMenu
            && !showHomeConfirm
    }

    private var boardPixelSide: CGFloat {
        CGFloat(board.size) * (BoardLayout.cellSize + BoardLayout.spacing)
    }

    private var boardFitScale: CGFloat {
        let horizontalMargin: CGFloat = 40
        let w = UIScreen.main.bounds.width - horizontalMargin
        let verticalReserve: CGFloat = 320
        let h = max(120, UIScreen.main.bounds.height - verticalReserve)
        let sw = w / boardPixelSide
        let sh = h / boardPixelSide
        return min(1, max(0.01, min(sw, sh)))
    }

    private var boardDisplayWidth: CGFloat {
        boardPixelSide * boardFitScale
    }

    var body: some View {
        ZStack {
            GameBackgrounds.starry.ignoresSafeArea()

            VStack(spacing: 12) {
                Image("kurukuruobake_01")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 40)
                    .padding(.bottom, 8)

                Text("ミッション　魂を \(board.missionTarget) 体解放")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(width: boardDisplayWidth, alignment: .center)
                    .frame(minHeight: 22, alignment: .center)

                Text("残り \(moveLimit - moveCount) 手")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: boardDisplayWidth, alignment: .center)
                    .padding(.bottom, 12)

                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Score")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        Text("\(board.score)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer(minLength: 12)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Best Score")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        Text("\(bestScore)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                    }
                }
                .frame(width: boardDisplayWidth)

                HStack {
                    Text("Stars: \(board.collectedStars)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer(minLength: 16)
                    Text("Ghosts: \(board.unlockedGhosts) / \(board.missionTarget)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(width: boardDisplayWidth)
                .padding(.bottom, 4)

                BoardView(board: board, selected: $selected)
                    .frame(width: boardPixelSide, height: boardPixelSide)
                    .scaleEffect(boardFitScale)
                    .frame(width: boardPixelSide * boardFitScale, height: boardPixelSide * boardFitScale)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if canInteract {
                                    let p = CGPoint(
                                        x: value.location.x / boardFitScale,
                                        y: value.location.y / boardFitScale
                                    )
                                    handleDrag(at: p, size: BoardLayout.cellSize, spacing: BoardLayout.spacing)
                                }
                            }
                            .onEnded { _ in
                                if canInteract {
                                    handleEnd()
                                }
                            }
                    )

                HStack {
                    Text("Time \(timeString)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                    Spacer()
                    Text("Moves \(moveCount)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                .frame(width: boardDisplayWidth)
                .padding(.top, 4)

                Spacer()
            }
            .blur(radius: showEndPopup || showSettingsMenu ? 8 : 0)

            // 右上設定
            if !showEndPopup {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showSettingsMenu = true
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.92))
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.28))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 48)
                        .padding(.trailing, 18)
                    }
                    Spacer()
                }
                .zIndex(30)
            }

            if showMissionBriefing {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .allowsHitTesting(missionBriefingOpacity > 0.08)

                    VStack(spacing: 10) {
                        Text("\(moveLimit)手ミッション")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        Text("魂を \(board.missionTarget) 体解放")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.black.opacity(0.78))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .opacity(missionBriefingOpacity)
                }
                .allowsHitTesting(missionBriefingOpacity > 0.08)
                .transition(.opacity)
            }

            if showEndPopup {
                EndPopupView(
                    score: board.score,
                    bestScore: UserDefaults.standard.integer(forKey: bestScoreKey),
                    starCount: board.collectedStars,
                    ghosts: board.unlockedGhosts,
                    missionTarget: board.missionTarget,
                    isClear: board.unlockedGhosts >= board.missionTarget,
                    imageName: endPopupImageName,
                    clearActionTitle: "次へ",
                    onNewGame: { resetGame() },
                    onClose: {
                        onGoHome()
                    },
                    onClosePopup: {
                        endPopupDismissed = true
                        playLockedAfterEnd = true
                    }
                )
            }

            if playLockedAfterEnd && endPopupDismissed {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        endPopupDismissed = false
                        withAnimation {
                            board.isGameOver = true
                        }
                    }
            }

            if board.showYukionnaIntroCard {
                YukionnaIntroCardView()
                    .transition(.opacity)
                    .zIndex(40)
            }

            if showSettingsMenu {
                PlaySettingsMenuView(
                    onHome: {
                        showHomeConfirm = true
                    },
                    onClose: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSettingsMenu = false
                        }
                    }
                )
                .zIndex(50)
                .transition(.opacity)
            }
        }
        .alert("ホームに戻りますか？", isPresented: $showHomeConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("ホームへ", role: .destructive) {
                showSettingsMenu = false
                SoundManager.shared.stopBGM()
                onGoHome()
            }
        } message: {
            Text("現在のプレイは終了します。")
        }
        .onChange(of: board.score) { _, newScore in
            let currentBest = UserDefaults.standard.integer(forKey: bestScoreKey)
            if newScore > currentBest {
                UserDefaults.standard.set(newScore, forKey: bestScoreKey)
            }
        }
        .onAppear {
            scheduleMissionBriefingDismissal()
            SoundManager.shared.playBGM()
        }
        .onChange(of: board.isGameOver) { _, isGameOverNow in
            guard isGameOverNow else { return }
            endPopupImageName = ["clear_01", "clear_02", "clear_03"].randomElement() ?? "clear_01"
        }
        .onReceive(playTimer) { _ in
            guard !showMissionBriefing,
                  !board.isGameOver,
                  !board.isGameOverPending,
                  !playLockedAfterEnd,
                  let start = gameStartTime else { return }
            displayElapsedSeconds = max(0, Int(Date().timeIntervalSince(start)))
        }
    }

    private func scheduleMissionBriefingDismissal() {
        showMissionBriefing = true
        missionBriefingOpacity = 1
        let fadeDelay: TimeInterval = 1.15
        let fadeDuration: TimeInterval = 0.75
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
            withAnimation(.easeOut(duration: fadeDuration)) {
                missionBriefingOpacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay + fadeDuration) {
            showMissionBriefing = false
            gameStartTime = Date()
            displayElapsedSeconds = 0
        }
    }

    private func resetGame() {
        withAnimation {
            board.isGameOver = false
            board.isGameOverPending = false
            board.resetBoard()
            board.score = 0
            board.collectedStars = 0
            board.unlockedGhosts = 0
            moveCount = 0
            gameStartTime = nil
            displayElapsedSeconds = 0
            endPopupDismissed = false
            playLockedAfterEnd = false
            selected.removeAll()
            dragColor = nil
            showSettingsMenu = false
            showHomeConfirm = false
        }
        scheduleMissionBriefingDismissal()
    }

    private func handleDrag(at location: CGPoint, size: CGFloat, spacing: CGFloat) {
        let totalCell = size + spacing
        let boardOffset = CGFloat(board.size - 1) / 2
        let localX = (location.x - (size / 2)) / totalCell - boardOffset
        let localY = (location.y - (size / 2)) / totalCell - boardOffset
        let col = Int((localX + boardOffset).rounded().clamped(to: 0...CGFloat(board.size - 1)))
        let row = Int((localY + boardOffset).rounded().clamped(to: 0...CGFloat(board.size - 1)))
        guard (0..<board.size).contains(row), (0..<board.size).contains(col) else { return }
        let coord = Coord(row: row, col: col)
        guard !board.tiles[row][col].isFrozen else { return }

        if dragColor == nil {
            dragColor = board.tiles[row][col].color
            selected = [coord]
            return
        }
        if board.tiles[row][col].color == dragColor && !selected.contains(coord) {
            if let last = selected.last {
                if abs(last.row - coord.row) <= 1 && abs(last.col - coord.col) <= 1 {
                    selected.append(coord)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }

    private func handleEnd() {
        if selected.count >= 3 {
            moveCount += 1
            if moveCount >= moveLimit {
                board.isGameOverPending = true
            }
            board.beginPlayerMove()
            board.processMatchedTiles(coords: selected)
            SoundManager.shared.playEffect(named: "chain1.mp3")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                board.removeAndDrop()
            }
        }
        selected.removeAll()
        dragColor = nil
    }
}
