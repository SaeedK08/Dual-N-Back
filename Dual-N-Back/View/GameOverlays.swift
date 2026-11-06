import SwiftUI

/// Shown when the player pauses. Pausing aborts the round, so the only choices are restart or home.
struct PauseOverlay: View {
    let onRestart: () -> Void
    let onHome: () -> Void

    var body: some View {
        OverlayCard {
            Text("Game Paused")
                .font(.title2)
                .fontWeight(.bold)
            Text("In N-Back, pausing aborts the round.\nWould you like to restart or return home?")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                OverlayButton(title: "Restart", systemImage: "arrow.clockwise", action: onRestart)
                OverlayButton(title: "Home", systemImage: "house.fill", isPrimary: false, action: onHome)
            }
        }
    }
}

/// Shown when a round ends: score, accuracy and the hit / miss / false alarm counts.
struct RoundFinishedOverlay: View {
    @EnvironmentObject var viewModel: GameViewModel
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    @State private var playerName = ""
    @State private var isSaved = false

    var body: some View {
        OverlayCard {
            Text("Round Complete!")
                .font(.title)
                .fontWeight(.bold)
            Text("\(viewModel.finalScore) pts")
                .font(.system(size: 40, weight: .bold))
            Text(String(format: "%.0f%% Accuracy", viewModel.finalPercentage))
                .font(.headline)
                .foregroundStyle(.secondary)
            HStack {
                stat("Hits", "\(viewModel.hits)", .green)
                stat("Misses", "\(viewModel.misses)", .red)
                stat("False alarms", "\(viewModel.falseTaps)", .orange)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Optional score saving
            if !isSaved {
                HStack {
                    TextField("Name (optional)", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                    Button("Save") {
                        viewModel.saveCurrentScore(playerName: playerName)
                        isSaved = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Score saved!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            HStack(spacing: 12) {
                OverlayButton(title: "Play Again", action: onPlayAgain)
                OverlayButton(title: "Return Home", isPrimary: false, action: onHome)
            }
        }
    }

    private func stat(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Dimmed background with a centred card. Compact enough to fit an iPhone in landscape.
private struct OverlayCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                content
            }
            .padding(20)
            .frame(maxWidth: 420)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 12)
            .padding(.horizontal, 24)
        }
    }
}

/// Filled (primary) or grey (secondary) button used in both overlays.
private struct OverlayButton: View {
    let title: String
    var systemImage: String? = nil
    var isPrimary = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.headline)
            .foregroundColor(isPrimary ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isPrimary ? Color.blue : Color(.systemGray5))
            .cornerRadius(12)
        }
    }
}
