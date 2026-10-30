//
//  GameView.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Game Screen")
                .font(.title)
                .fontWeight(.bold)
            
            Text("N-Back round placeholder")
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("N-Back")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(GameViewModel())
    }
}
