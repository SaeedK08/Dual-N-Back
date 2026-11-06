//
//  SettingsView.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-31.
//

import SwiftUI

/// Settings sheet allowing users to customize round parameters.
struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Game Difficulty Section
                Section(header: Text("Difficulty")) {
                    Stepper(value: $viewModel.settings.n, in: 1...8) {
                        HStack {
                            Label("N-Back Level", systemImage: "brain.head.profile")
                            Spacer()
                            Text("N = \(viewModel.settings.n)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Stepper(value: $viewModel.settings.eventsPerRound, in: 10...50, step: 5) {
                        HStack {
                            Label("Events Per Round", systemImage: "number")
                            Spacer()
                            Text("\(viewModel.settings.eventsPerRound)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Stepper(value: $viewModel.settings.eventDuration, in: 1.0...3.0, step: 0.5) {
                        HStack {
                            Label("Event Duration", systemImage: "clock")
                            Spacer()
                            Text(String(format: "%.1f s", viewModel.settings.eventDuration))
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Stimuli Configuration Section
                Section(header: Text("Stimuli Setup"), footer: Text("Visual grid size affects active cells. Letter count restricts auditory stimuli to the first N phonetically distinct letters.")) {
                    Stepper(value: $viewModel.settings.gridSize, in: 3...5) {
                        HStack {
                            Label("Grid Size", systemImage: "square.grid.3x3")
                            Spacer()
                            Text("\(viewModel.settings.gridSize)×\(viewModel.settings.gridSize) (\(viewModel.settings.gridSize * viewModel.settings.gridSize) cells)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Stepper(value: $viewModel.settings.letterCount, in: 4...8) {
                        HStack {
                            Label("Distinct Letters", systemImage: "character")
                            Spacer()
                            Text("\(viewModel.settings.letterCount) letters")
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Display active letters preview
                    HStack {
                        Text("Active Letters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(viewModel.letters.prefix(viewModel.settings.letterCount).joined(separator: ", ").uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameViewModel())
}
