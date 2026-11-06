import SwiftUI

/// Visual stimulus grid (gridSize x gridSize). The active cell lights up.
/// Stays square on every screen: the side is the smaller of the available width and height.
struct GridBoardView: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let cellSpacing: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellCount = viewModel.settings.gridSize
            let cellSide = max(0, (side - cellSpacing * CGFloat(cellCount - 1)) / CGFloat(cellCount))

            VStack(spacing: cellSpacing) {
                ForEach(0..<cellCount, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<cellCount, id: \.self) { column in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isActive(row: row, column: column) ? Color.blue : Color(.systemGray5))
                                .frame(width: cellSide, height: cellSide)
                                .animation(.easeInOut(duration: viewModel.stimulusOnTime), value: viewModel.currentVisualItem)
                        }
                    }
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// True if this cell is the one highlighted for the current event.
    private func isActive(row: Int, column: Int) -> Bool {
        viewModel.currentVisualItem == row * viewModel.settings.gridSize + column
    }
}

#Preview("Square") {
    GridBoardView()
        .environmentObject(GameViewModel())
        .frame(width: 320, height: 320)
}

#Preview("Wide and short (landscape)") {
    GridBoardView()
        .environmentObject(GameViewModel())
        .frame(width: 500, height: 200)
}
