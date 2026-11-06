import SwiftUI

/// Game screen: HUD, stimulus area and match buttons.
/// On iPhone in landscape (compact height) the match buttons move to the sides (H-04).
/// This view only arranges things. The grid sizes itself (GridBoardView), so there are no size calculations here.
struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showPauseOverlay = false

    private var showsAudioButton: Bool { viewModel.settings.stimulusMode != .visual }
    private var showsVisualButton: Bool { viewModel.settings.stimulusMode != .auditory }

    var body: some View {
        ZStack {
            Group {
                if verticalSizeClass == .compact {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .blur(radius: showPauseOverlay || viewModel.phase == .finished ? 3 : 0)

            if showPauseOverlay {
                PauseOverlay(onRestart: restartRound, onHome: leaveGame)
            }
            if viewModel.phase == .finished {
                RoundFinishedOverlay(onPlayAgain: { viewModel.startRound() }, onHome: leaveGame)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.startRound() }
        .onDisappear { viewModel.cancelRound() }
        .onChange(of: scenePhase) { _, newPhase in
            // App moved to the background mid-round: stop the timer and ask what to do (D-09).
            if newPhase != .active && viewModel.phase == .running {
                pauseRound()
            }
        }
    }

    // MARK: - Layouts

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            hud
                .padding([.horizontal, .top])
            StimulusAreaView()
                .frame(maxWidth: 360, maxHeight: .infinity)
                .padding()
            HStack(spacing: 2) {
                if showsAudioButton { MatchButton(modality: .audio) }
                if showsVisualButton { MatchButton(modality: .visual) }
            }
            .frame(height: 150)
        }
    }

    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            if showsAudioButton {
                MatchButton(modality: .audio)
                    .frame(width: 140)
            }
            VStack(spacing: 8) {
                hud
                    .padding(.horizontal)
                    .padding(.top, 4)
                StimulusAreaView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            if showsVisualButton {
                MatchButton(modality: .visual)
                    .frame(width: 140)
            }
        }
    }

    // MARK: - HUD

    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Event \(viewModel.currentEventNumber) of \(viewModel.settings.eventsPerRound)")
                    .font(.headline)
                Text("Correct: \(viewModel.correctResponses)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: pauseRound) {
                Image(systemName: "pause.fill")
                    .font(.title2)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Pause round")
        }
    }

    // MARK: - Actions

    /// Stops the round timer and shows the pause card. Pausing aborts the round.
    private func pauseRound() {
        viewModel.cancelRound()
        showPauseOverlay = true
    }

    private func restartRound() {
        showPauseOverlay = false
        viewModel.startRound()
    }

    private func leaveGame() {
        showPauseOverlay = false
        viewModel.cancelRound()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(GameViewModel())
    }
}
