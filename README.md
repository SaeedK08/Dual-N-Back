# Dual N-Back — Cognitive Working Memory Training (iOS / iPadOS)

A native iOS and iPadOS Dual N-Back application built with **Swift**, **SwiftUI**, and **Core Data**, developed for university course HI1033 / CM2023. 

The application implements all basic (B-01–B-09), detailed (D-01–D-09), and all **four** higher-level requirements (H-01–H-05), featuring strict MVVM architecture, comprehensive unit testing, and zero third-party dependencies.

---

## 🌟 Key Features

### 1. Training Modes & Dual N-Back (H-01)
- **Visual Mode:** Highlights dynamic cells across a scalable grid ($3\times3$, $4\times4$, $5\times5$).
- **Auditory Mode:** Speaks phonetically distinct letters (`C`, `H`, `K`, `L`, `Q`, `R`, `S`, `T`) designed to eliminate acoustic confusion.
- **Dual Mode:** Simultaneous, independent visual and auditory sequences with dedicated input tracks and independent match evaluation.

### 2. Sequence Engine & Anti-Spam Scoring
- **Sequence Logic (B-08):** Guarantees that the first $N$ events can never be matches ($i - n < 0$), with an empirical match-rate strictly enforced between 20% and 40%.
- **Weighted Scoring (B-09, Q11):** Weighted points (Hit: `+2`, False Tap: `-2`, Miss: `-1`) with a hard floor at zero (`max(0, ...)`), mathematically neutralizing button spamming.
- **Division-by-Zero Protection:** Defensive calculations prevent `NaN` or crashes if zero matches occur.

### 3. Persistent Settings (H-02)
- Configure N-Back level ($1$–$8$), event duration ($1.0$–$3.0\text{s}$), events per round ($10$–$50$), grid dimensions ($3\times3$–$5\times5$), and letter vocabulary count ($4$–$8$).
- Auto-persists to disk via `UserDefaults` using `JSONEncoder` through a clean `didSet` observer.

### 4. Core Data Score History (H-03)
- Persists player name, score, N-level, and completion timestamp to an ACID-compliant local **SQLite** database via Core Data.
- Interactive **Score History** screen featuring `NSSortDescriptor` sorting:
  - **By Score:** Highest score first (with date tie-breaking).
  - **By Date:** Most recent round first.
  - **By Name:** Alphabetical order ($A$–$Z$) using case-insensitive comparison.

### 5. Responsive Layout & Ergonomics (H-04)
- **Dynamic Geometry (Q24):** The grid calculates `min(width, height)` with `.aspectRatio(1, contentMode: .fit)`, guaranteeing an exact 1:1 square on any screen size without clipping.
- **Two-Thumb Landscape Mode:** On iPhone in landscape (`verticalSizeClass == .compact`), match controls transform into full-height left and right sidebars right under the player's thumbs, leaving the center clear for the grid.

### 6. Accessibility & TTS Fallback (H-05)
- **Oversized Touch Targets (Q25):** Match buttons measure $150\text{pt}$ tall in portrait and $140\text{pt}$ wide full-height in landscape ($\approx 15\times$ to $28\times$ larger than Apple's $44\times44\text{pt}$ HIG minimum).
- **Text-To-Speech Fallback (Q20):** If system speech voices are unavailable, the app automatically switches to an on-screen visual letter fallback with non-blocking user alerts.
- **VoiceOver:** All controls include explicit accessibility labels and hints.

### 7. Smooth Stimulus Fade UX
- Features an exact split-timer loop (`stimulusOnTime` + remaining interval) paired with ease-in-out animations, allowing cells to smoothly light up and fade back to neutral before subsequent events appear.

---

## 📁 Project Architecture & File Structure

The project follows a clean **MVVM (Model-View-ViewModel)** separation where business logic is 100% decoupled from the UI:

```text
Dual-N-Back/
├── Dual_N_BackApp.swift          # App Entry point; instantiates @StateObject and injects .environmentObject
│
├── Model/                        # Pure Swift business logic & persistence (No SwiftUI imports)
│   ├── GameSettings.swift        # Codable configuration struct with UserDefaults save/load
│   ├── PersistenceController.swift # Core Data stack singleton (NSPersistentContainer & viewContext)
│   ├── ScoreCalculator.swift     # Anti-spam scoring formula, percentage math, and division-by-zero guards
│   ├── ScoreModel.xcdatamodeld   # XML data model schema defining ScoreEntry entity
│   ├── ScoreRepository.swift     # Repository layer providing CRUD & NSSortDescriptor queries
│   ├── SequenceGenerator.swift   # Stimulus generator with injected RNG and 20%–40% match enforcement
│   └── StimulusTrack.swift       # Event tracking, double-press prevention, hit/false-tap/miss tallies
│
├── ViewModel/                    # Observable state machine & round timer
│   └── GameViewModel.swift       # State machine (idle/running/finished), cooperative async Task loop, HUD state
│
├── Services/                     # Hardware & system service abstractions
│   └── SpeechService.swift       # AVSpeechSynthesizer singleton manager with voice availability checks
│
├── View/                         # Declarative, modular SwiftUI interface
│   ├── GameOverlays.swift        # Dimmed PauseOverlay and RoundFinishedOverlay (with optional score save)
│   ├── GameView.swift            # Main game orchestrator switching between portrait and landscape layouts
│   ├── GridBoardView.swift       # Dynamic, square GeometryReader grid with smooth fade animations
│   ├── HomeView.swift            # Home screen with high score banner, mode picker, settings card, and navigation
│   ├── MatchButton.swift         # Reusable, full-width/full-height match button with animated feedback
│   ├── ScoreHistoryView.swift    # Core Data score leaderboard with segmented sorting (Score / Date / Name)
│   ├── SettingsView.swift        # Form with steppers and constraints to configure game parameters
│   └── StimulusAreaView.swift    # Center container switching on visual, audio, or dual modes + TTS fallback
│
└── Dual_N_BackTests/             # Automated test suite
    └── Dual_N_BackTests.swift    # 13 comprehensive XCTests (100% passing in 0.001s)
```

---

## 🧪 Unit Test Suite (`Dual_N_BackTests`)

The test suite covers core business logic, boundary edge cases, and mutation verification:

| Test Case | Component | Verification |
| :--- | :--- | :--- |
| `testSequenceLengthMatchesRequested` | `SequenceGenerator` | Exact sequence length; all items within item range. |
| `testZeroMatchRateProducesNoMatches` | `SequenceGenerator` | 0% boundary check: zero matches generated for $i \ge n$. |
| `testFullMatchRateProducesAllMatches` | `SequenceGenerator` | 100% boundary check: all events for $i \ge n$ are matches. |
| `testTargetMatchRateEnforced` | `SequenceGenerator` | Statistical test over 50 rounds (1,000 events) proves 20%–40% compliance. |
| `testScoreCalculationWithPerfectRound` | `ScoreCalculator` | 5 hits calculate to 10 points and 100% accuracy. |
| `testScoreNeverDropsBelowZero` | `ScoreCalculator` | Raw negative points safely floor at 0. |
| `testSpammingYieldsZeroScore` | `ScoreCalculator` | Equal hits and false taps neutralize to 0 pts and 0% accuracy. |
| `testZeroMatchesReturnsZeroWithoutCrashing` | `ScoreCalculator` | Zero matches safely returns (0, 0.0) without division by zero. |
| `testMatchPressIgnoredDuringFirstNEvents` | `StimulusTrack` | Pressing match when $i < n$ is ignored (D-07). |
| `testDoublePressOnSameEventIsIgnored` | `StimulusTrack` | Duplicate presses within the same event tick are ignored (D-08, Q28). |
| `testCorrectMatchIncrementsHits` | `StimulusTrack` | Valid match press increments hit count. |
| `testIncorrectMatchIncrementsFalseTaps` | `StimulusTrack` | Non-match press increments false tap count. |
| `testUnpressedMatchIncrementsMissesOnAdvance` | `StimulusTrack` | Unpressed match increments misses on tick advance. |

---

## 🚀 Getting Started & Startup Manual

### System Requirements
- **macOS:** macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
- **IDE:** Xcode 15 or Xcode 16 (available free on the Mac App Store)
- **Deployment Target:** iOS 17.0+ / iPadOS 17.0+
- **Dependencies:** **Zero external dependencies** (no CocoaPods, no SPM, no Carthage).

### Running in Xcode (3 Steps)

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd Dual-N-Back
   ```

2. **Open the Xcode project:**
   ```bash
   open Dual-N-Back.xcodeproj
   ```

3. **Build, Run & Test:**
   - Select any simulator target at the top (e.g., **iPhone 16** or **iPad Pro**).
   - Press **`⌘R`** (`Cmd + R`) to build and run the app.
   - Press **`⌘U`** (`Cmd + U`) to run all 13 unit tests.

*(No developer team certificate or provisioning profile is required when targeting the iOS Simulator).*
