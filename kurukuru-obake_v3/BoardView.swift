//
//  BoardView.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/15.
//

import SwiftUI

/// ボード全体で共有するタイル寸法（`ContentView` のドラッグ計算と一致させる）
enum BoardLayout {
    static let cellSize: CGFloat = 52
    static let spacing: CGFloat = 2
    /// 落下アニメの縦幅（旧 44px 基準の 65 に比例）
    static var fallCellHeight: CGFloat { cellSize * (65.0 / 44.0) }
}

// MARK: - BoardView（ボード全体＋星座ライン）
struct BoardView: View {
    @ObservedObject var board: GameBoard
    @Binding var selected: [Coord]
    @Environment(\.colorScheme) var colorScheme
    @State private var ascendingGhosts: [Coord] = []
    
    private var cellSize: CGFloat { BoardLayout.cellSize }
    private var spacing: CGFloat { BoardLayout.spacing }
    
    var body: some View {
        ZStack {
            // 🎨 ボード背景：システムのガラス風マテリアル（背後の星空がぼかし越しに見える）
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.28 : 0.55),
                                    Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .frame(
                    width: CGFloat(board.size) * (cellSize + spacing) + 8,
                    height: CGFloat(board.size) * (cellSize + spacing) + 8
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.22), radius: 14, y: 6)
            
            GeometryReader { geo in
                ZStack {
                    // 🧩 タイル群
                    ForEach(0..<board.size, id: \.self) { row in
                        ForEach(0..<board.size, id: \.self) { col in
                            let tile = board.tiles[row][col]
                            let x = geo.size.width / 2 + (CGFloat(col) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                            let y = geo.size.height / 2 + (CGFloat(row) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                            let selIndex = selected.firstIndex { $0.row == row && $0.col == col }

                            TileView(
                                tile: tile,
                                isSelected: selIndex != nil,
                                tileSize: cellSize
                            )
                            .frame(width: cellSize, height: cellSize)
                            .contentShape(Rectangle())
                            .offset(y: tile.fallOffset)
                            .opacity(tile.opacity)
                            .position(x: x, y: y)
                            // なぞり順が後のタイルほど手前に（二重○が隣にかかる）
                            .zIndex(selIndex.map { 10 + Double($0) } ?? 1)
                            .onChange(of: tile.isMatched) { matched in
                                if matched && tile.isGhost {
                                    let coord = Coord(row: row, col: col)
                                    if !ascendingGhosts.contains(coord) {
                                        ascendingGhosts.append(coord)
                                    }
                                }
                            }
                        }
                    }

                    // 👾 盤面の裏から現れて魂を凍結する夜の悪戯もの
                    if let mischiefCoord = board.mischiefCoord {
                        let x = geo.size.width / 2 + (CGFloat(mischiefCoord.col) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                        let y = geo.size.height / 2 + (CGFloat(mischiefCoord.row) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)

                        Image("yukionna")
                            .resizable()
                            .scaledToFit()
                            .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                            .position(x: x, y: y)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.15).combined(with: .opacity),
                                    removal: .scale(scale: 0.05).combined(with: .opacity)
                                )
                            )
                            .zIndex(24)
                    }

                    // 💫 消えたタイルの位置にキラキラを出す
                    ForEach(board.sparkles, id: \.self) { coord in
                        let x = geo.size.width / 2 + (CGFloat(coord.col) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                        let y = geo.size.height / 2 + (CGFloat(coord.row) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                        
                        SparkleEffect(trigger: true)
                            .frame(width: 60, height: 60)
                            .position(x: x, y: y)
                            .zIndex(10)
                    }
                    
                    // 👻 昇天アニメーションレイヤー
                    ForEach(ascendingGhosts, id: \.self) { coord in
                        let x = geo.size.width / 2 + (CGFloat(coord.col) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                        let y = geo.size.height / 2 + (CGFloat(coord.row) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)

                        GhostView {
                            // アニメ終了後にリストから削除
                            ascendingGhosts.removeAll { $0 == coord }
                        }
                        .position(x: x, y: y)
                        .zIndex(20)
                    }
                    
                    // 🌟 なぞり経路（選択中はタイルより手前に・色は白固定）
                    if selected.count > 1 {
                        Path { path in
                            for (index, coord) in selected.enumerated() {
                                let x = geo.size.width / 2 + (CGFloat(coord.col) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                                let y = geo.size.height / 2 + (CGFloat(coord.row) - CGFloat(board.size - 1) / 2) * (cellSize + spacing)
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            Color.white.opacity(0.95),
                            style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: Color.white.opacity(0.55), radius: 6, y: 1)
                        .shadow(color: .white.opacity(0.35), radius: 2)
                        .animation(.easeInOut(duration: 0.12), value: selected)
                        .zIndex(15)
                    }
          
                    // 🌟⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️
                    // 💫 スコアポップアップをここに入れる！！！
                    ForEach(board.popups, id: \.id) { popup in
                        ScorePopup(points: popup.points, position: popup.position)
                            .position(
                                x: popup.position.x,
                                y: popup.position.y
                            )
                            .zIndex(30)
                    }
                }
            }
            // 外側の○が隣マスにかかるのでわずか余白
            .padding(8)
        }
        .frame(
            width: CGFloat(board.size) * (cellSize + spacing),
            height: CGFloat(board.size) * (cellSize + spacing)
        )
    }
}

// MARK: - タイル見た目（TileView）
struct TileView: View {
    var tile: Tile
    var isSelected: Bool = false
    var tileSize: CGFloat = BoardLayout.cellSize
    @State private var disappearProgress: CGFloat = 1.0

    private var ghostIconSize: CGFloat { 26 * tileSize / 44 }

    var body: some View {
        ZStack {
            // 🟪 通常タイル背景
            OctagonShape()
                .fill(tile.color)
                .opacity(tile.opacity)
                .frame(width: tileSize, height: tileSize)
                .scaleEffect(tile.isMatched ? disappearProgress : 1.0)
                .opacity(tile.isMatched ? Double(disappearProgress) : 1.0)
                .animation(.easeInOut(duration: 0.3), value: tile.isMatched)

            // なぞり中：◎はその下、星は手前（「星を繋ぐ」／空のマスに星が立つ）
            if isSelected {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.95), lineWidth: 3.4)
                        .padding(-7)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.78)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3.8
                        )
                        .padding(2)
                }
                .shadow(color: .white.opacity(0.55), radius: 4, y: 0)
                .zIndex(0)
            }

            // 👻 ゴースト封印タイル（装飾なし・アイコンのみ）
            if tile.isGhost {
                Image("ghost_01")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ghostIconSize, height: ghostIconSize)
                    .opacity(0.92)
                    .offset(y: 1)
                    .transition(.opacity)
                    .zIndex(1)
            } else if isSelected && tile.color != .clear {
                Image(systemName: "star.fill")
                    .font(.system(size: tileSize * 0.44, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.88)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: 0.5)
                    .zIndex(2)
            }

            if tile.freezeLevel >= 2 {
                Image("koori_01")
                    .resizable()
                    .scaledToFit()
                    .frame(width: tileSize * 1.18, height: tileSize * 1.18)
                    .blendMode(.screen)
            } else if tile.freezeLevel == 1 {
                Image("koori_01")
                    .resizable()
                    .scaledToFit()
                    .frame(width: tileSize * 1.18, height: tileSize * 1.18)
                    .opacity(0.5)
                    .blendMode(.screen)
            }
        }
        /// フラット見せ：単色の薄い縁取りのみ
        .overlay {
            OctagonShape()
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isSelected)
        .animation(.easeInOut(duration: 0.25), value: tile.freezeLevel)
        // 💫 消去アニメーション
        .onChange(of: tile.isMatched) { matched in
            if matched {
                withAnimation(.easeInOut(duration: 0.15)) {
                    disappearProgress = 0.0
                }
            } else {
                disappearProgress = 1.0
            }
        }
    }
}

// MARK: - MovingHighlight（反射アニメーション）
struct MovingHighlight: View {
    @State private var move = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                Color.white.opacity(0.6),
                .clear
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .blendMode(.screen)
        .rotationEffect(.degrees(10))
        .offset(x: move ? 80 : -80, y: move ? 80 : -80)
        .animation(
            Animation.easeInOut(duration: 2.5)
                .repeatForever(autoreverses: false)
                .delay(Double.random(in: 0...1.5)), // 反射タイミングをランダム化
            value: move
        )
        .onAppear {
            move = true
        }
    }
}

// MARK: - 八角形シェイプ
struct OctagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.28
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + inset))
        path.closeSubpath()
        return path
    }
}
