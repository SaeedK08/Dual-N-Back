import SwiftUI

/// Centre of the game screen: the grid, the spoken-letter card, or both (dual), depending on the stimulus mode.
/// Shows the letter on screen when no speech voice is available (H-05, exam Q20).
struct StimulusAreaView: View {
    @EnvironmentObject var viewModel: GameViewModel

    /// The current letter as text, or a dash before the first event.
    private var currentLetter: String {
        viewModel.currentAudioItem.map { viewModel.letters[$0].uppercased() } ?? "—"
    }

    var body: some View {
        switch viewModel.settings.stimulusMode {
        case .visual:
            GridBoardView()
        case .auditory:
            audioCard
        case .dual:
            VStack(spacing: 8) {
                GridBoardView()
                audioStatus
            }
        }
    }

    /// Auditory-only card. Fills the available space as a square (like the grid), so it also fits in landscape.
    private var audioCard: some View {
        VStack(spacing: 8) {
            if viewModel.isVoiceAvailable {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.purple)
                Text("Listen for the letter")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Label("Voice unavailable", systemImage: "speaker.slash.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                Text(currentLetter)
                    .font(.system(size: 64, weight: .bold))
                    .minimumScaleFactor(0.5)
                Text("Visual letter fallback active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .aspectRatio(1, contentMode: .fit)
    }

    /// Small status line under the grid in dual mode.
    @ViewBuilder
    private var audioStatus: some View {
        if viewModel.isVoiceAvailable {
            Label("Audio active", systemImage: "speaker.wave.2.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Label("Sound fallback: \(currentLetter)", systemImage: "speaker.slash.fill")
                .font(.subheadline.bold())
                .foregroundColor(.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

#Preview {
    StimulusAreaView()
        .environmentObject(GameViewModel())
}
