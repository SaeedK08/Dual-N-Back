import SwiftUI

/// One match button (position or sound). Colours itself from the ViewModel's feedback state,
/// is disabled during the first n events, and forwards user taps.
/// A large, full-section button meeting Apple's touch-target guidelines.
struct MatchButton: View {
    enum Modality { case visual, audio }

    @EnvironmentObject var viewModel: GameViewModel
    let modality: Modality

    private var isBeforeN: Bool {
        viewModel.currentEventNumber <= viewModel.settings.n
    }

    private var title: String {
        modality == .visual ? "POSITION" : "SOUND"
    }

    private var systemImage: String {
        modality == .visual ? "square.grid.3x3.fill" : "speaker.wave.2.fill"
    }

    /// Background and text colour. Grey while presses are not allowed, otherwise from the latest feedback.
    private var colors: (background: Color, text: Color) {
        if isBeforeN { return (Color(.systemGray4), Color(.systemGray)) }

        let feedback = modality == .visual ? viewModel.visualFeedback : viewModel.audioFeedback
        switch feedback {
        case .none: return (.blue, .white)
        case .hit: return (.green, .white)
        case .falseTap: return (.yellow, .black)
        case .miss: return (.red, .white)
        }
    }

    var body: some View {
        Button {
            if modality == .visual {
                viewModel.registerVisualMatch()
            } else {
                viewModel.registerAudioMatch()
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundColor(colors.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // The colour fills the safe-area edges (home indicator, notch) while the label stays inside.
            .background(colors.background.ignoresSafeArea())
            // Ensures the entire rectangle area is tappable
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isBeforeN)
        .animation(.easeInOut(duration: 0.2), value: colors.background)
        .accessibilityLabel(modality == .visual ? "Position Match" : "Sound Match")
        .accessibilityHint("Registers a match if the current \(modality == .visual ? "position" : "sound") matches \(viewModel.settings.n) steps back")
    }
}
