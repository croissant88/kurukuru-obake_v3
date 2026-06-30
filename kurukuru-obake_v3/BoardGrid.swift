//
//  BoardGrid.swift.swift
//  KurukuruObake
//
//  Created by くるくるランプ on 2025/10/15.
//

// MARK: - GameBoardGrid.swift
import SwiftUI

struct GameBoardGrid: View {   // ← ここを BoardGrid → GameBoardGrid に変更
    @ObservedObject var board: GameBoard
    @Binding var selected: [Coord]
    
    var body: some View {
        let cellSize: CGFloat = 44
        let spacing: CGFloat = 2
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .frame(width: CGFloat(board.size) * (cellSize + spacing),
                       height: CGFloat(board.size) * (cellSize + spacing))
            
            VStack(spacing: spacing) {
                ForEach(0..<board.size, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<board.size, id: \.self) { col in
                            let tile = board.tiles[row][col]
                            TileView(tile: tile, isSelected: selected.contains { $0.row == row && $0.col == col })
                        }
                    }
                }
            }
            .frame(
                width: CGFloat(board.size) * (cellSize + spacing),
                height: CGFloat(board.size) * (cellSize + spacing)
            )
        }
    }
}
