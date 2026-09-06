import SwiftUI
import Combine

struct ContentView: View {
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
    @State private var showSettingsMenu = false
    private let playTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    private var moveLimit: Int {
        board.mission.moveLimit
    }

    private var timeString: String {
        let s = displayElapsedSeconds
        return String(format: "%02d:%02d", s / 60, s % 60)
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
            && !board.showFriendGetCard
            && !playLockedAfterEnd
            && !showSettingsMenu
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
                HStack {
                    Spacer()
                    if !showEndPopup {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showSettingsMenu = true
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.92))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.28))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
                .frame(height: 36)

                Image("kurukuruobake_01")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                Text(board.mission.headline)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(width: boardDisplayWidth, alignment: .center)

                Text(board.mission.shortTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(width: boardDisplayWidth, alignment: .center)
                    .frame(minHeight: 22, alignment: .center)

                Text("残り \(moveLimit - moveCount) 手")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: boardDisplayWidth, alignment: .center)
                    .padding(.bottom, 12)

                HStack {
                    Text("星屑 \(board.collectedStars)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer(minLength: 16)
                    Text("解放した魂 \(board.unlockedGhosts) / \(board.missionTarget)")
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
                    Text("時間 \(timeString)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                    Spacer()
                    Text("手数 \(moveCount)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                .frame(width: boardDisplayWidth)
                .padding(.top, 4)

                Spacer()
            }
            .blur(radius: showEndPopup || showSettingsMenu ? 8 : 0)

            if showMissionBriefing {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())

                    VStack(spacing: 12) {
                        Text(board.mission.headline)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text(board.mission.shortTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Rectangle()
                            .fill(Color.gray.opacity(0.55))
                            .frame(height: 1)
                            // .padding(.top, 2)
                        Text(board.mission.body)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 2)
                        Text("魂 \(board.missionTarget) 体　／　\(moveLimit) 手")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 26)
                    .frame(maxWidth: 320)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.black.opacity(0.78))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissMissionBriefing()
                }
                .transition(.opacity)
            }

            if showEndPopup {
                EndPopupView(
                    starCount: board.collectedStars,
                    ghosts: board.unlockedGhosts,
                    missionTarget: board.missionTarget,
                    isClear: board.unlockedGhosts >= board.missionTarget,
                    imageName: endPopupImageName,
                    clearActionTitle: "次へ",
                    memoryFragmentTitle: board.newlyFoundFragment?.title,
                    onNewGame: {
                        let didClear = board.unlockedGhosts >= board.missionTarget
                        resetGame(keepMission: !didClear)
                    },
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

            if board.showFriendGetCard, let friend = board.newlyBefriendedFriend {
                FriendGetCardView(friend: friend) {
                    board.finishFriendGetAndShowResult()
                }
                .transition(.opacity)
                .zIndex(55)
            }

            if showSettingsMenu {
                PlaySettingsMenuView(
                    mission: board.mission,
                    onHome: {
                        showSettingsMenu = false
                        onGoHome()
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
        .onAppear {
            presentMissionBriefing()
            // BGM は Home で開始済み。未再生時のみ保険で開始する
            SoundManager.shared.playBGM()
        }
        .onChange(of: board.isGameOver) { _, isGameOverNow in
            guard isGameOverNow else { return }
            let didClear = board.unlockedGhosts >= board.missionTarget
            if didClear {
                endPopupImageName = ["clear_01", "clear_02", "clear_03"].randomElement() ?? "clear_01"
            } else {
                endPopupImageName = ["over_01", "over_02", "over_03"].randomElement() ?? "over_01"
            }
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

    private func presentMissionBriefing() {
        showMissionBriefing = true
        gameStartTime = nil
        displayElapsedSeconds = 0
    }

    private func dismissMissionBriefing() {
        withAnimation(.easeOut(duration: 0.2)) {
            showMissionBriefing = false
        }
        gameStartTime = Date()
        displayElapsedSeconds = 0
    }

    private func resetGame(keepMission: Bool = false) {
        withAnimation {
            board.isGameOver = false
            board.isGameOverPending = false
            board.resetBoard(keepMission: keepMission)
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
        }
        presentMissionBriefing()
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
