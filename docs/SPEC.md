# SPEC.md: Lab B:1, Native N-Back Mobile App

> **Living document.** Read this file and `STYLE.md` at the start of every session, before writing or
> suggesting any code. Update it as described in section 1. Keep it short and accurate; delete
> anything that is no longer true.

---

## 1. How to use and maintain this file (meta-instructions)

### 1.1 For the AI agent

1. At the start of every session, read `SPEC.md` and `STYLE.md`. If they conflict with a request, say so.
2. Treat section 3 (requirements) as the source of truth. Do not add features that are not listed.
3. Before the student builds a component, help them write its short entry in section 7 (what it does,
   edge cases, how it will be tested). Do not start from code.
4. After every decision, change of plan or discovered problem, propose the matching update to this
   file (checkbox, decision log row, open question, template note). Apply it once the student agrees.
5. At the end of every session, run the end-of-session ritual in section 9.3.
6. Never mark a requirement as done unless the student has run it and can explain it.

### 1.2 For the student

- This file is a working agreement between you and the agent, and later the source for your oral exam
  preparation (section 8).
- You may edit it directly at any time. The agent proposes, you decide.

### 1.3 When to update which section

| Event | Update |
|---|---|
| A requirement works and is tested | Tick its box in section 3, add the test name |
| You make a design choice (and why) | Add a row to the decision log (section 6) |
| Something is unclear in the lab text | Add to open questions (section 5); fill in the answer when you get it |
| You build or change a component | Update its entry in section 7 |
| You find where an oral exam question is answered in code | Fill in the location in section 8 |
| A session ends | Run the ritual in section 9.3 |

---

## 2. Project facts

| Item | Value |
|---|---|
| Course / lab | HI1033 / CM2023, Lab B:1 "Building a Native N-Back Mobile App" (teacher: Jonas Willén) |
| Individual work | Yes. Must pass B:1 before B:2 and B:3 |
| Platform | iOS, Swift, SwiftUI, Xcode (assumed from the teacher's skeleton repo; **confirm, see Q-01**) |
| Target grade | **Full marks (2 points)**: basic + dual n-back + three higher-level items |
| Skeleton repo | https://github.com/JonasWillen/N-Back-SwiftUI (dated 2023). **Reference only, not our project** (see section 4 and D-004). Structure example: https://github.com/JonasWillen/TicTacToe |
| Project setup | New Xcode project created from scratch by following `initiate_project.md` |
| Submission deadline | At least one day before the scheduled oral presentation. Planned: end of next week (**fill in exact date: ______**) |
| Oral exam | Open code, answer questions from the list in section 8. Opening question is always Q26 |
| External libraries | None beyond the platform SDK |
| docs/N-back-lab 1.pdf |  The original lab instructions and description given from the teacher |

**Submission contains four parts:**
1. Code (MVVM, descriptive names, documented; no god-class)
2. LLM process document (`docs/LLM_PROCESS.md`)
3. Test report (`docs/TEST_REPORT.md`) + the test files
4. Reflection (`docs/REFLECTION.md`)

The submission must also contain a short statement of which parts were AI-assisted and which tools and
prompts were used. This lives in `docs/LLM_PROCESS.md`. Attach `SPEC.md` and `STYLE.md` as the context
files given to the LLM.

---

## 3. Requirements checklist

Legend: `[ ]` not started, `[~]` in progress, `[x]` done, tested and explainable.
Each requirement has an ID so that tests, decisions and notes can refer to it.

### 3.1 Basic (1 point)

- [ ] **B-01** Home screen shows the current high score.
- [ ] **B-02** Home screen lets the player choose visual, auditory, or both.
- [ ] **B-03** Home screen displays current settings: stimulus type, n, event duration, events per round.
- [ ] **B-04** Game screen shows the 3x3 grid (visual) and/or plays spoken letters (auditory).
- [ ] **B-05** Game screen shows live state: current event number and number of correct responses.
- [ ] **B-06** Game screen has a match button and a control to start a new round.
- [ ] **B-07** Non-offensive animated feedback on an incorrect press (colour or size animation, no harsh red/buzzer).
- [ ] **B-08** Sequence logic written by us: match rate about 20-40 %, first n events can never be matches.
- [ ] **B-09** Unit tests for at least three of: sequence generation, match-rate enforcement, first-n guarantee,
  double-press prevention, scoring formula. Tests are runnable and pass. (Plan: test all five if time allows.)

### 3.2 Detailed requirements (all mandatory)

- [ ] **D-01** One cell highlighted per event in a 3x3 grid.
- [ ] **D-02** Auditory stimuli are spoken letters from a fixed, phonetically distinct set.
- [ ] **D-03** Controls to start a new round and to register a match.
- [ ] **D-04** Home screen shows stimulus type, n, event duration, events per round.
- [ ] **D-05** Game screen shows current event number and number of correct responses.
- [ ] **D-06** Non-offensive animated feedback on incorrect press.
- [ ] **D-07** Match press ignored before the round starts, after it ends, and during the first n events.
- [ ] **D-08** Multiple presses on the same event ignored after the first.
- [ ] **D-09** Round timer cancelled cleanly when the round ends or the player leaves the screen mid-round.

### 3.3 Higher level (2 points)

- [ ] **H-01** Dual n-back: visual and auditory sequences at the same time, independent sequences, independent match logic.
- [ ] Three of the following four (**choose and record in the decision log**):
  - [ ] **H-02** Settings screen, persistent: events per round, event duration, n, grid size, number of distinct letters.
  - [ ] **H-03** Score history: save score under a name; separate screen listing scores sortable by name, score, date; local database (Core Data + `NSSortDescriptor`).
  - [ ] **H-04** Responsive layout: portrait and landscape, phone and tablet (test on iPhone and iPad simulators).
  - [ ] **H-05** Accessibility: minimum touch target on the match button; TTS fallback message when no voice is available.

**Chosen three:** ______ , ______ , ______  (decided on: ______, reason: ______)

### 3.4 Constraints from the lab text

- Architecture: MVVM (MVC acceptable). A single god-class is not acceptable.
- Class, method and field names describe their purpose. Code is documented.
- Settings persist with `UserDefaults`; scores with Core Data (platform hints in the lab).
- `AVSpeechSynthesizer` is initialised once and speaks per event; speech only after a user gesture.
- Anything the LLM wrote must be verified and tested by the student before submitting.

---

## 4. Teacher skeleton: what it contains (inspected 2026-10-29)

| Part | State |
|---|---|
| `Model/nback.c`, `nback.h`, bridging header | C generator: `create(size, combinations, matchPercentage, n)` and `getIndexOf`. Called from Swift through the bridging header |
| `N_Back_SwiftUIModel.swift` | Demo code only (`getString`, `addScore`, `resetNback` hardcodes `create(20, 9, 20, 2)`) |
| `N_Back_SwiftUIVM.swift` | `ObservableObject` with `AVSpeechSynthesizer` and a `@Published highScore`; demo methods only |
| `ContentView.swift` | Placeholder UI. Does not compile as committed: preview struct lacks `PreviewProvider` |
| Tests | None |

**Known problems in `nback.c` (found by running it):**
- `srand(time(NULL))` on every call: two calls in the same second return identical sequences (breaks dual n-back).
- `fillInAMatch` can loop forever when no free slot is left (observed hang at 40 % requested, n = 3, 20 events).
- Match rate drifts above the requested value (30 % requested gave about 34.7 % actual) because filler values can create extra matches.
- Off-by-one: `i-nback > 0` should be `>= 0`.
- Memory from `malloc` is never freed.
- Values are 1-9 (cell = value - 1).

**Current plan:** the N-Back skeleton is **not** used as our project. We create a new Xcode project and
build a clean skeleton from the teacher's structure (`initiate_project.md`), without `nback.c`, the
bridging header or the demo code. We write our own sequence generator in Swift. See D-004.

### 4.1 Teacher's TicTacToe example: what to copy and what not (inspected 2026-10-30)

TicTacToe is the teacher's example of MVVM structure and calls. Files: `TicTacToeApp.swift`,
`TicTacToeVM.swift` at the root, `Model/TicTacToeModel.swift`, and `View/` (views plus `VoiceIO.swift`).
No tests. Project settings: iPhone + iPad, all orientations, iOS 18.1 deployment target, Swift 5 mode.

| Pattern in TicTacToe | In our project |
|---|---|
| `@main` App creates the ViewModel with `@StateObject` and injects it with `.environmentObject(...)`; views read it with `@EnvironmentObject` | **Copy** (exam Q15) |
| ViewModel is `@MainActor class ...: ObservableObject` with `@Published` view state and a `private var theModel` | **Copy** |
| Model is a plain `struct` with `mutating` functions and no SwiftUI import | **Copy** (exam Q17) |
| ViewModel converts model data into view data (`markers`) | **Copy the idea**: grid highlight state for the views |
| Every view has a preview | **Copy** |
| `VoiceIO`: one `AVSpeechSynthesizer`, `AVAudioSession` set to `.playback` / `.spokenAudio` / `.duckOthers`, stops speech in progress before speaking, `en-US` voice | **Adapt** as `SpeechService` (one `speak(_:)` instead of four copy-pasted methods) |
| `VoiceIO` lives in `View/` | **Change**: it is not a view, it goes in `Services/` |
| "Hurry up" uses `DispatchQueue.main.asyncAfter` with a captured move count | **Do not copy for the round timer**: it cannot be cancelled, which breaks D-09. Use a cancellable timer owned by the ViewModel |
| `TextInfo` calls `checkWinner()` inside `body`, and that call changes model state | **Do not copy**: no side effects in `body`; the ViewModel publishes state |
| Game state as magic integers (0/1/2/3) | **Do not copy**: use enums (for example the game phase) |
| Fixed 300x300 board and `.position(x:y:)` | **Do not copy**: breaks Q24 and H-04; use `GeometryReader` or `aspectRatio` |
| `ContentView` and `MainView` are duplicates | **Do not copy** |
| `.DS_Store` and `xcuserdata` are committed, no tests | **Fix**: `.gitignore` and a test target from the start |

---

## 5. Open questions for the teacher

| ID | Question | Answer | Date |
|---|---|---|---|
| Q-01 | Is iOS / SwiftUI with the provided skeleton OK as our platform? | | |
| Q-02 | May we use `nback.c` as it is, or must we write our own generator? May we change or fix it? (Lower priority now: we write our own either way, see D-004.) | | |
| Q-03 | Is there an updated skeleton for this year? `ContentView.swift` does not compile. (Moot: we do not use the skeleton project, see D-004.) | | |
| Q-04 | In basic level, does "both" mean one combined sequence with one match button, or two sequences with two buttons? | | |
| Q-05 | Is the 20-40 % match rate measured over all events or only events after the first n? Must every round fall in the range or only the average? | | |
| Q-06 | May we choose the scoring formula and weights ourselves? | | |
| Q-07 | In dual n-back, does the "first n events cannot be matches" rule apply per sequence? | | |
| Q-08 | Must unit tests be Swift (XCTest) or may we test C code too? | | |
| Q-09 | How and when do we book the presentation slot, and where is the submission uploaded? | | |

Until answered, the assumptions in the decision log apply.

---

## 6. Decision log

Add one row per real decision, newest last. Keep the "why" short. Wrong decisions are not deleted,
they are marked **superseded by D-xxx**. The reasons are what the oral exam asks about (Q11, Q17, Q27).

| ID | Date | Decision | Why | Alternatives considered | Status |
|---|---|---|---|---|---|
| D-001 | 2026-10-29 | Keep skeleton structure, write generator in Swift, remove demo code | Generator has real bugs; we must be able to test and explain every line; XCTest without C interop | Use `nback.c` unchanged | **Superseded by D-004** (same structure, but in a new project) |
| D-002 | 2026-10-29 | Design for dual n-back from the start: one `ModalityState` per modality | Avoids rewriting the core later | Add dual afterwards | Active |
| D-003 | 2026-10-29 | Generator takes its own random source | Two independent sequences, and deterministic tests | Global `rand()` | Active |
| D-004 | 2026-10-30 | New Xcode project from scratch. The teacher's N-Back and TicTacToe repos are read-only references; broken or demo parts (`nback.c`, bridging header, demo code, duplicate views) are not carried over | We must be able to explain every line; the skeleton has real bugs and does not compile | Clone the skeleton and fix it | Active |
| D-005 | 2026-10-30 | Follow TicTacToe's wiring: `@StateObject` ViewModel in the App, `.environmentObject`, `@EnvironmentObject` in views, `@MainActor ObservableObject` ViewModel, Model as plain structs | Matches what the teacher expects to see (Q15, Q17) | `@Observable` macro | Active |
| D-006 | 2026-10-30 | Folders: `Model/`, `ViewModel/`, `View/`, `Services/`. Speech is a service, not in `View/` | Clearer layers than TicTacToe, which puts `VoiceIO` in `View/` | Copy TicTacToe layout exactly | Active |

---

## 7. Component specs (filled in *before* each component is built)

For each component write: purpose, inputs/outputs, edge cases, which tests cover it, requirement IDs.
Start with a few lines, not a full design. Add the entry first, then code.

### 7.1 Planned components

| Component | Layer | Responsibility | Requirements | Status |
|---|---|---|---|---|
| `SequenceGenerator` | Model | Produces a sequence for n, length, symbol count, target match rate; first n never match; per-event match decision | B-08, D-01, D-02 | Not started |
| `ModalityState` (name TBD) | Model | One modality's sequence, current event, match flag, press guard, hit/miss/false-alarm counts | D-07, D-08, H-01 | Not started |
| `ScoreCalculator` | Model | Score from hits, misses, false alarms; never below 0 | B-09 | Not started |
| `GameViewModel` | ViewModel | State machine (idle / running / finished), round timer, press handling, publishes state | D-07, D-09, B-05 | Not started |
| `SpeechService` | Service | `AVSpeechSynthesizer` initialised once, speaks letters, no-voice fallback | D-02, H-05 | Not started. Agent may draft it later, adapted from the teacher's `VoiceIO` (section 4.1); student must read and explain it |
| Home / Game views | View | Render state only; no game logic; navigation lives here, not in the ViewModel | B-01 to B-07 | Not started |
| Settings store | Persistence | `UserDefaults` read/write | H-02 | Optional |
| Score store | Persistence | Core Data entity, sorted query | H-03 | Optional |

### 7.2 Entry template (copy per component)

```
#### <Component name>
- Purpose:
- Inputs / outputs:
- Rules and edge cases (e.g. n larger than sequence length, 100 % or 0 % match rate requested):
- Tests that cover it (names):
- Requirement IDs:
- Notes / what changed during development:
```

---

## 8. Oral exam map (fill in as the code appears)

For each question, record where the answer lives (file and function) and the test that backs it.
A question with an empty location at the end of development means something is missing.

| Q | Topic | Code location | Test | Status |
|---|---|---|---|---|
| 1 | Generator: where, returns, test | | | |
| 2 | Match-rate enforcement, where decided per event | | | |
| 3 | First-n guarantee | | | |
| 4 | One stimulus from generation to output (visual + audio) | | | |
| 5 | State machine and every transition | | | |
| 6 | One full event tick end to end | | | |
| 7 | Round-over detection and cleanup | | | |
| 8 | Guard before start / after end / first n events | | | |
| 9 | Second press on same event prevented | | | |
| 10 | Hits, misses, false alarms on press and silent tick | | | |
| 11 | Score formula, weights, no negative score | | | |
| 12 | Where the timer is cancelled; leaving the screen | | | |
| 13 | Wrong-press feedback, why non-offensive | | | |
| 14 | HUD updates | | | |
| 15 | Observable state wiring (`@Published`, subscriptions) | | | |
| 16 | Navigation, why ViewModel does not navigate | | | |
| 17 | Testable logic separated from UI | | | |
| 18 | TTS init, where letters are spoken, why after a gesture | | | |
| 19 | Letter set and why those letters | | | |
| 20 | No voice available | | | |
| 21 | One settings write and read | | | |
| 22 | Score entity, sorted query, why a database | | | |
| 23 | What runs off the main thread | | | |
| 24 | Grid stays square across devices and orientations | | | |
| 25 | Touch target size, safe areas | | | |
| 26 | What I wrote vs. what AI wrote (**opening question**) | `docs/LLM_PROCESS.md` | n/a | |
| 27 | Which three or more components have tests, and why | `docs/TEST_REPORT.md` | | |
| 28 | Double-press guard code + test that catches its removal | | | |
| 29 | Run a test live; a production change that would make it fail | | | |
| 30 | Did any test catch a real bug? | `docs/TEST_REPORT.md` | | |

---

## 9. Submission documents: create now, update progressively

**Create all three files in `docs/` at the start of the first session** (with the headings below, mostly
empty). They are written during development, not at the end. A missing or late entry is a process
problem, so the agent reminds the student at every session end.

### 9.1 `docs/LLM_PROCESS.md` (target: about 1 page when submitted)

Required content by the lab: tools used; context files given to the LLM; two or three representative prompts
and what they produced; what the LLM got wrong and had to be corrected. Also the statement of which parts
were AI-assisted.

Structure:

```
# LLM process document
## Tools used            (tool, model, how it was used)
## Context files given   (SPEC.md, STYLE.md, version/date)
## Who wrote what        (table: component | written by me | AI-assisted | AI-generated, reviewed by me)
## Representative prompts (2-3, each: prompt gist, what it produced, what I changed)
## What the AI got wrong (each: what, how I found it, how I fixed it)

---
## Working log (raw material; condense into the sections above before submission)
| Date | Task | What I asked | What I got | What I changed / why | AI mistake? |
```

- **Update trigger:** end of every session (section 9.3), and immediately when the AI makes a mistake.
- **Who writes:** the agent drafts log rows from the session, the student corrects and approves them.
- **Before submission:** condense the log into the top sections and trim to about one page. Keep the log in an appendix only if it still fits.

### 9.2 `docs/TEST_REPORT.md` (short)

Required content by the lab: which parts of the logic were tested, which test cases, the results. The test
files are attached.

Structure:

```
# Test report
## Summary                (how to run: command/scheme; total tests; pass/fail)
## Tested components      (which and why these; see exam Q27)
## Test cases             (table: test name | component | requirement ID | what it asserts | result)
## Bugs found by tests    (what failed, why, how fixed; see exam Q30)
## Mutation checks        (production change that makes each key test fail; see exam Q29)
## Not tested             (what and why)
```

- **Update trigger:** every time a test is written or changed, a test fails unexpectedly, or a bug is found.
- **Rule:** each key test gets a mutation check: temporarily break the production code and confirm the test fails. Record it. The double-press test (Q28) is mandatory.
- **Who writes:** the agent drafts table rows, the student runs the tests and records real results. Never write a result that was not run.

### 9.3 `docs/REFLECTION.md` (about half a page when submitted)

Required content by the lab: one thing that surprised you about working with AI, and one thing you would do
differently next time.

Structure:

```
# Reflection
## Final text (about half a page)
   - One thing that surprised me about working with AI:
   - One thing I would do differently next time:

---
## Running notes (dated, 1-3 lines each, written in my own words)
```

- **Update trigger:** after each milestone, and whenever something surprises you, is hard, or goes wrong.
- **Who writes:** **the student only, in their own words.** The agent may ask a prompt question ("what surprised you today?") but must not write the notes or the final text.
- **Before submission:** pick the best surprise and the best "do differently" from the running notes and write the final half page.

### 9.4 End-of-session ritual (agent runs this at the end of every session)

1. Ask: "What did we finish, what did we decide, what went wrong?"
2. Propose updates to SPEC.md: checkboxes (section 3), decision log (6), component entries (7), oral exam map (8), open questions (5).
3. Draft new rows for the working log in `docs/LLM_PROCESS.md`, including any AI mistake.
4. Draft new rows for the test table in `docs/TEST_REPORT.md` if tests changed.
5. Ask the student for one or two lines for the running notes in `docs/REFLECTION.md`.
6. Ask the student to explain back one piece of code written today (teach-back, see `STYLE.md`).
7. Note the next step and the biggest open risk in section 10.

---

## 10. Plan and status

Working days counted from the start of work. Adjust dates when Q-09 is answered.

| Phase | Content | Done when |
|---|---|---|
| Day 0 | Create the project by following `initiate_project.md`; first commit | App builds and shows placeholder Home/Game screens, test target runs, `docs/` files exist |
| Day 1-2 | Send teacher questions. Write spec entries. Generator + tests (sequence, match rate, first-n) | Three generator tests pass and are mutation-checked |
| Day 3-4 | State machine, timer, press guards, scoring, HUD. Basic version playable | D-01 to D-09 and B-01 to B-09 ticked |
| Day 5-6 | Dual n-back (H-01), then the three chosen higher-level items | H-items ticked |
| Day 7 | Condense `docs/` files to final length. Check code documentation and naming | Four submission parts complete |
| Day 8 | Mock oral exam on the 30 questions. Fixes. Submit at least one day before the presentation | Section 8 has no empty locations |

**Current status:** (update each session)
- Last session: ______
- Next step: ______
- Biggest risk: ______

---

## 11. Definition of done

- [ ] All of section 3.1 and 3.2 ticked; H-01 and three chosen higher-level items ticked
- [ ] Unit tests run and pass from a clean checkout (at least three required; aim for five)
- [ ] Every key test has a recorded mutation check
- [ ] Code follows MVVM, no god-class, names descriptive, public types and non-obvious logic documented
- [ ] Timer verified to cancel on round end and on leaving the screen
- [ ] Section 8 has a code location for every question, and I can explain each line there without help
- [ ] `docs/LLM_PROCESS.md` (about 1 page), `docs/TEST_REPORT.md`, `docs/REFLECTION.md` (about half a page) complete; `SPEC.md` and `STYLE.md` attached
- [ ] Tested on iPhone and iPad simulators if H-04 is chosen
- [ ] Submitted at least one day before the presentation
