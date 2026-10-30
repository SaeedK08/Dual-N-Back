# initiate_project.md: Empty project skeleton

> **For the AI agent.** Read `SPEC.md` and `STYLE.md` first. Task: turn the new, empty Xcode project into a
> skeleton with the folder and file structure of the teacher's repos, keeping only the good parts.
> The skeleton has **no Core logic and no tests**. Everything is empty or placeholder.

## Inputs

- New Xcode project (created by the student, SwiftUI, XCTest, Storage None): `current directory`
- Teacher's N-Back clone (read-only): `../N-Back-SwiftUI`
- My version of the teacher's tutorial for tictactoe: `../TicTacToe`

Do not edit `project.pbxproj` by hand. If new files do not join the target, ask the student to add them in Xcode.

## What to build

Mirror the teacher's structure (App file and ViewModel, `Model/`, `View/`), with one extra `Services/` folder (SPEC D-006):

```
<Project>/
  <Project>App.swift          App entry: @StateObject GameViewModel, .environmentObject (as in TicTacToeApp)
  ViewModel/
    GameViewModel.swift       empty `@MainActor final class GameViewModel: ObservableObject`
  Model/
    GameSettings.swift        stimulus mode, n, event duration, events per round (plain struct, defaults only)
    SequenceGenerator.swift   empty struct + one-line doc comment
    ModalityState.swift       empty struct + one-line doc comment
    ScoreCalculator.swift     empty struct + one-line doc comment
  Services/
    SpeechService.swift       adapted from the teacher's VoiceIO: one AVSpeechSynthesizer, audio session setup,
                              a single `speak(_:)` (not four copies). You can also look up mine (far simpler and clearer that the teacher's)  at  ../TicTacToe/TicTacToe/View/VoiceIO.swift, which I really like, simple and functional! 
  View/
    HomeView.swift           placeholder text + NavigationLink to GameView, uses @EnvironmentObject
    GameView.swift           placeholder text, uses @EnvironmentObject
```

- Each view has a `#Preview` that injects `GameViewModel()`.
- Delete Xcode's default `ContentView.swift`. Leave the test target as it is.
- Core files stay empty. The student fills them in, spec entry first.

## Left out on purpose

`nback.c`, `nback.h`, the bridging header, the demo code, the duplicate and broken views, fixed 300x300 layout,
the `asyncAfter` timer, `xcuserdata` and `.DS_Store` (details: `SPEC.md` section 4.1).

## Done when

The project builds in Xcode and shows the placeholder Home screen. Tell the student what you created and
why, then stop.