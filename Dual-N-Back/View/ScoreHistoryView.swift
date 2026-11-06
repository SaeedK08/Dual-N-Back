//
//  ScoreHistoryView.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-31.
//

import SwiftUI

/// Score history screen sortable by Score, Date, or Name.
struct ScoreHistoryView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var sortOption: ScoreSortOption = .score

    var body: some View {
        VStack(spacing: 8) {
            Picker("Sort by", selection: $sortOption) {
                Text("Score").tag(ScoreSortOption.score)
                Text("Date").tag(ScoreSortOption.date)
                Text("Name").tag(ScoreSortOption.name)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: sortOption) { _, newOption in
                viewModel.loadScoreHistory(orderBy: newOption)
            }

            if viewModel.scoreHistory.isEmpty {
                Spacer()
                Text("No scores saved yet.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(viewModel.scoreHistory) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.playerName ?? "Anonymous")
                                .font(.headline)
                            if let date = entry.date {
                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(entry.score) pts")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("N = \(entry.nLevel)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Score History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadScoreHistory(orderBy: sortOption)
        }
    }
}

#Preview {
    NavigationStack {
        ScoreHistoryView()
            .environmentObject(GameViewModel())
    }
}
