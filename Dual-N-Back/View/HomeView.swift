//
//  HomeView.swift
//  Dual-N-Back
//
//  Created by Saeed Kassab on 2026-10-30.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Dual N-Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Working Memory Training")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // High Score Card
                    highScoreCard

                    // Mode Selector
                    modeSelectorSection

                    // Current Settings Summary
                    settingsSummaryCard

                    // Start Training Button
                    NavigationLink(destination: GameView()) {
                        Text("Start Training")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink(destination: ScoreHistoryView()) {
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        }
                        .accessibilityLabel("Score History")

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - High Score Card
    private var highScoreCard: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("HIGH SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Text("\(viewModel.highestScore) pts")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    // MARK: - Stimulus Mode Selector
    private var modeSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STIMULUS MODE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            Picker("Stimulus Mode", selection: $viewModel.settings.stimulusMode) {
                Text("Visual").tag(StimulusMode.visual)
                Text("Audio").tag(StimulusMode.auditory)
                Text("Dual").tag(StimulusMode.dual)
            }
            .pickerStyle(.segmented)

            // TTS Fallback Notice
            if !viewModel.isVoiceAvailable && viewModel.settings.stimulusMode != .visual {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.slash.fill")
                        .foregroundColor(.orange)
                    Text("No speech voice detected. A visual letter fallback will be displayed during the round.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Settings Summary Card (Requirements B-03 & D-04)
    private var settingsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CURRENT SETTINGS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                settingRow(label: "N-Back Level", value: "N = \(viewModel.settings.n)")
                Divider()
                settingRow(label: "Event Duration", value: String(format: "%.1fs", viewModel.settings.eventDuration))
                Divider()
                settingRow(label: "Events Per Round", value: "\(viewModel.settings.eventsPerRound)")
                Divider()
                settingRow(label: "Grid Size", value: "\(viewModel.settings.gridSize)×\(viewModel.settings.gridSize)")
                Divider()
                settingRow(label: "Distinct Letters", value: "\(viewModel.settings.letterCount)")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }

    private func settingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GameViewModel())
}
