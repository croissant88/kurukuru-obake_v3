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
    @Published var isGameClear = false
    @Published var popups: [ScorePopupData] = []
    
    @Published var isVictoryPending = false

    let missionTarget: Int

    let size = 8
    
    init(missionTarget: Int = 5) {
        self.missionTarget = missionTarget
        resetBoard()
    }
    
    func resetBoard() {
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

    func showFinalPopup() {
        guard !isGameClear else { return }
        DispatchQueue.main.async {
            withAnimation {
                self.isGameClear = true
                self.isVictoryPending = false
            }
        }
    }

    // ✅ 消去とカウントの共通ルール
    func processMatchedTiles(coords: [Coord]) {
        let uniqueCoords = Array(Set(coords))
        let ghostCount = uniqueCoords.filter { tiles[$0.row][$0.col].isGhost }.count
        
        if ghostCount > 0 {
            unlockedGhosts += ghostCount
            if unlockedGhosts >= missionTarget && !isVictoryPending {
                isVictoryPending = true
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

    func autoMatchAndRemove() {
        var matchedCoords: [Coord] = []
        
        // 縦横チェック
        for row in 0..<size {
            for col in 0..<size - 2 {
                let c = tiles[row][col].color
                if c != .clear && tiles[row][col + 1].color == c && tiles[row][col + 2].color == c {
                    matchedCoords += [Coord(row: row, col: col), Coord(row: row, col: col + 1), Coord(row: row, col: col + 2)]
                }
            }
        }
        for col in 0..<size {
            for row in 0..<size - 2 {
                let c = tiles[row][col].color
                if c != .clear && tiles[row + 1][col].color == c && tiles[row + 2][col].color == c {
                    matchedCoords += [Coord(row: row, col: col), Coord(row: row + 1, col: col), Coord(row: row + 2, col: col)]
                }
            }
        }
        
        guard !matchedCoords.isEmpty else {
            if chainCount > 0 { chainCount = 0 }
            if isVictoryPending { showFinalPopup() }
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
}
