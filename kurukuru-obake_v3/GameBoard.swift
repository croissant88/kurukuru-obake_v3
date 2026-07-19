import SwiftUI
import Combine

// MARK: - Tile Struct
struct Tile: Identifiable, Equatable {
    let id = UUID()
    var color: Color
    var isMatched = false
    var fallOffset: CGFloat = 0
    var opacity: Double = 1.0
    var isGhost: Bool = false
    var freezeLevel: Int = 0
    var isFrozen: Bool { freezeLevel > 0 }
    let isActive: Bool = true
}

struct Coord: Hashable {
    let row: Int
    let col: Int
}

struct ScorePopupData: Identifiable {
    let id = UUID()
    let points: Int
    let position: CGPoint
}

class GameBoard: ObservableObject {
    @Published var tiles: [[Tile]] = []
    @Published var isNightMode = false
    @Published var chainCount: Int = 0
    @Published var sparkles: [Coord] = []
    @Published var score: Int = 0
    @Published var collectedStars: Int = 0
    @Published var unlockedGhosts: Int = 0
    @Published var missionTarget = 18
    @Published var isGameOver = false
    @Published var isGameOverPending = false
    @Published var isMissionClearPending = false
    @Published var mischiefCoord: Coord?
    @Published var isMischiefAnimating = false
    @Published var popups: [ScorePopupData] = []

    let size = 8
    private let maxFrozenTiles = 8
    private var movesUntilMischief = Int.random(in: 5...8)
    private var isPlayerMovePending = false
    private var boardSessionID = UUID()
    
    init() {
        resetBoard()
    }
    
    func resetBoard() {
        boardSessionID = UUID()
        missionTarget = 18
        movesUntilMischief = Int.random(in: 5...8)
        isPlayerMovePending = false
        isMissionClearPending = false
        mischiefCoord = nil
        isMischiefAnimating = false
        tiles = (0..<size).map { row in
            (0..<size).map { col in
                var tile = Tile(color: GameColors.all.randomElement() ?? .blue)
                if Double.random(in: 0..<1) < 0.10 {
                    tile.isGhost = true
                }
                return tile
            }
        }
    }

    func beginPlayerMove() {
        isPlayerMovePending = true
    }

    func showGameOver() {
        guard !isGameOver else { return }
        DispatchQueue.main.async {
            withAnimation {
                self.isGameOver = true
                self.isGameOverPending = false
                self.isMissionClearPending = false
            }
        }
    }

    @discardableResult
    func freezeTile(at coord: Coord) -> Bool {
        guard (0..<size).contains(coord.row),
              (0..<size).contains(coord.col),
              tiles[coord.row][coord.col].color != .clear,
              !tiles[coord.row][coord.col].isFrozen else {
            return false
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            tiles[coord.row][coord.col].freezeLevel = 2
        }
        return true
    }

    // ✅ 消去とカウントの共通ルール
    func processMatchedTiles(coords: [Coord]) {
        let uniqueCoords = Array(Set(coords))
        thawFrozenTiles(adjacentTo: uniqueCoords)
        let ghostCount = uniqueCoords.filter { tiles[$0.row][$0.col].isGhost }.count
        
        if ghostCount > 0 {
            unlockedGhosts += ghostCount
            if unlockedGhosts >= missionTarget {
                isMissionClearPending = true
            }
        }
        
        // 星のカウント（通常タイル＝色つき）とスコア
        let normalCount = uniqueCoords.count - ghostCount
        collectedStars += normalCount
        let n = uniqueCoords.count
        // 長く繋ぐほど伸びる（3個より多い分にボーナス）
        let lengthBonus = n > 3 ? (n - 3) * 8 : 0
        score += n * 10 + lengthBonus + (ghostCount * 50)
        
        withAnimation(.easeOut(duration: 0.25)) {
            for coord in uniqueCoords {
                tiles[coord.row][coord.col].isMatched = true
            }
        }
    }

    private func thawFrozenTiles(adjacentTo matchedCoords: [Coord]) {
        guard !matchedCoords.isEmpty else { return }

        var frozenTilesToThaw: [Coord] = []
        for row in 0..<size {
            for col in 0..<size where tiles[row][col].isFrozen {
                let frozenCoord = Coord(row: row, col: col)
                let isAdjacentToMatch = matchedCoords.contains { matchedCoord in
                    let rowDistance = abs(matchedCoord.row - frozenCoord.row)
                    let colDistance = abs(matchedCoord.col - frozenCoord.col)
                    return max(rowDistance, colDistance) == 1
                }

                if isAdjacentToMatch {
                    frozenTilesToThaw.append(frozenCoord)
                }
            }
        }

        guard !frozenTilesToThaw.isEmpty else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            for coord in frozenTilesToThaw {
                tiles[coord.row][coord.col].freezeLevel = max(
                    0,
                    tiles[coord.row][coord.col].freezeLevel - 1
                )
            }
        }
    }

    func autoMatchAndRemove() {
        var matchedCoords: [Coord] = []
        
        // 縦横チェック
        for row in 0..<size {
            for col in 0..<size - 2 {
                let c = tiles[row][col].color
                if c != .clear
                    && !tiles[row][col].isFrozen
                    && !tiles[row][col + 1].isFrozen
                    && !tiles[row][col + 2].isFrozen
                    && tiles[row][col + 1].color == c
                    && tiles[row][col + 2].color == c {
                    matchedCoords += [Coord(row: row, col: col), Coord(row: row, col: col + 1), Coord(row: row, col: col + 2)]
                }
            }
        }
        for col in 0..<size {
            for row in 0..<size - 2 {
                let c = tiles[row][col].color
                if c != .clear
                    && !tiles[row][col].isFrozen
                    && !tiles[row + 1][col].isFrozen
                    && !tiles[row + 2][col].isFrozen
                    && tiles[row + 1][col].color == c
                    && tiles[row + 2][col].color == c {
                    matchedCoords += [Coord(row: row, col: col), Coord(row: row + 1, col: col), Coord(row: row + 2, col: col)]
                }
            }
        }
        
        guard !matchedCoords.isEmpty else {
            if chainCount > 0 { chainCount = 0 }
            if isMissionClearPending {
                isPlayerMovePending = false
                showGameOver()
            } else if isGameOverPending {
                isPlayerMovePending = false
                showGameOver()
            } else {
                finishPlayerMoveIfNeeded()
            }
            return
        }
        
        chainCount += 1
        
        // ✅ 共通ルールでカウント
        processMatchedTiles(coords: matchedCoords)
        
        // 音の再生
        let hasGhost = matchedCoords.contains { tiles[$0.row][$0.col].isGhost }
        let soundName = hasGhost ? "chain4.mp3" : "chain\(min(chainCount, 3)).mp3"
        SoundManager.shared.playEffect(named: soundName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.removeAndDrop()
        }
    }

    func removeAndDrop() {
        var newSparkles: [Coord] = []
        for row in 0..<size {
            for col in 0..<size {
                if tiles[row][col].isMatched { newSparkles.append(Coord(row: row, col: col)) }
            }
        }
        if !newSparkles.isEmpty {
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.2)) { self.sparkles = newSparkles }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            for coord in newSparkles {
                self.tiles[coord.row][coord.col].isMatched = false
                self.tiles[coord.row][coord.col].color = .clear
            }
            self.startTileFall()
        }
    }

    private func startTileFall() {
        let cellHeight: CGFloat = BoardLayout.fallCellHeight
        for col in 0..<self.size {
            var newColumn: [Tile] = []
            var fallOffsets: [Int: Int] = [:]
            var emptyCount = 0
            for row in stride(from: self.size - 1, through: 0, by: -1) {
                if self.tiles[row][col].color == .clear { emptyCount += 1 }
                else {
                    if emptyCount > 0 { fallOffsets[row] = emptyCount }
                    newColumn.append(self.tiles[row][col])
                }
            }
            let missing = self.size - newColumn.count
            for i in 0..<missing {
                var newTile = Tile(color: GameColors.all.randomElement() ?? .blue)
                if Double.random(in: 0..<1) < 0.15 { newTile.isGhost = true }
                newTile.fallOffset = -CGFloat(missing - i) * cellHeight
                newTile.opacity = 0.0
                newColumn.append(newTile)
            }
            for row in 0..<self.size { self.tiles[self.size - 1 - row][col] = newColumn[row] }
            withAnimation(.easeOut(duration: 0.4)) {
                for (row, offset) in fallOffsets {
                    self.tiles[row + offset][col].fallOffset = 0
                    self.tiles[row + offset][col].opacity = 1.0
                }
                for row in 0..<missing {
                    self.tiles[row][col].fallOffset = 0
                    self.tiles[row][col].opacity = 1.0
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.autoMatchAndRemove()
        }
    }

    private func finishPlayerMoveIfNeeded() {
        guard isPlayerMovePending else { return }
        isPlayerMovePending = false
        movesUntilMischief -= 1

        guard movesUntilMischief <= 0 else { return }
        triggerMischiefIfPossible()
    }

    private func triggerMischiefIfPossible() {
        let frozenTileCount = tiles
            .flatMap { $0 }
            .filter(\.isFrozen)
            .count
        let availableGhostCenters = (0..<size).flatMap { row in
            (0..<size).compactMap { col -> Coord? in
                let tile = tiles[row][col]
                let coord = Coord(row: row, col: col)
                guard tile.isGhost,
                      !tile.isFrozen,
                      !tile.isMatched,
                      nearbyNormalTiles(around: coord).count >= 3 else {
                    return nil
                }
                return coord
            }
        }

        guard maxFrozenTiles - frozenTileCount >= 4,
              let center = availableGhostCenters.randomElement() else {
            movesUntilMischief = 2
            return
        }

        let nearbyTargets = nearbyNormalTiles(around: center)
            .shuffled()
            .prefix(3)
        let targets = [center] + Array(nearbyTargets)

        movesUntilMischief = Int.random(in: 5...8)
        isMischiefAnimating = true
        let sessionID = boardSessionID

        withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) {
            mischiefCoord = center
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            guard self.boardSessionID == sessionID else { return }
            for target in targets {
                self.freezeTile(at: target)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            guard self.boardSessionID == sessionID else { return }
            withAnimation(.easeIn(duration: 0.28)) {
                self.mischiefCoord = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) {
            guard self.boardSessionID == sessionID else { return }
            self.isMischiefAnimating = false
        }
    }

    private func nearbyNormalTiles(around center: Coord) -> [Coord] {
        let rowRange = max(0, center.row - 1)...min(size - 1, center.row + 1)
        let colRange = max(0, center.col - 1)...min(size - 1, center.col + 1)

        return rowRange.flatMap { row in
            colRange.compactMap { col -> Coord? in
                let coord = Coord(row: row, col: col)
                let tile = tiles[row][col]
                guard coord != center,
                      !tile.isGhost,
                      !tile.isFrozen,
                      !tile.isMatched,
                      tile.color != .clear else {
                    return nil
                }
                return coord
            }
        }
    }
}
