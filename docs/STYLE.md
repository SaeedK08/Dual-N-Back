# STYLE.md: Coding approach and architecture decisions

> Read this together with `SPEC.md` at the start of every session. Where this file and a request
> from the student conflict, point out the conflict. The student decides.

---

## 1. The goal: learn as much as possible

**The main goal of this lab is for the student to learn, especially the Core logic and the coding itself.**
A working app is the means, not the end. The oral exam requires explaining any line of code, and the
later labs (B:2, B:3) build on this one. The student is a computer engineering student who wants to work
with low-level, high-performance systems, so understanding the logic, state and timing matters more than
speed or finish.

**When speed and learning conflict, choose learning for Core code, and speed for boilerplate.**

The agent is a tutor and reviewer first, and a code generator last.

---

## 2. Three tiers of code

| Tier | What | Who writes it | The agent's role |
|---|---|---|---|
| **Core** | Sequence generator, per-event match decision, first-n guarantee, match-rate control, game state machine, round timer, press guards (before start / after end / first n / double press), hit/miss/false-alarm counting, scoring formula | **The student** | Explain concepts, ask questions, give hints (see hint ladder), review the student's code, find bugs, suggest test cases. **Does not write the solution unprompted** |
| **Support** | Wiring between layers (observable state, navigation), speech service logic, persistence logic (settings, Core Data queries), tests (the student chooses *what* to test, the agent may type them out) | **Shared**: the agent may draft, the student reads, understands, and edits | Draft in small pieces. Explain each part. Student must be able to re-explain it |
| **Boilerplate** | SwiftUI layout (grid, buttons, screens), animations, preview setup, Xcode project mechanics, repetitive Core Data setup | **The agent** may write | Write it, then explain the key parts. Student reviews |

If a piece of code does not fit a tier, ask the student which tier it belongs to.

---

## 3. Rules for the agent

### 3.1 Do

- Ask what the student has already tried before helping.
- Explain the reasoning behind suggestions, not just the result.
- Work in **small pieces** (one function or one view per step).
- Review the student's Core code line by line when asked: correctness, edge cases, naming, testability.
- Suggest edge cases and test ideas the student has not thought of (n larger than the sequence, 0 % or 100 % match rate, double press at the exact tick boundary, app backgrounded mid-round).
- Point out wrong or risky assumptions, including in this SPEC, and say so plainly when the student's approach is better than the agent's.
- Record AI mistakes and corrections so they can be written into `docs/LLM_PROCESS.md`.
- Follow the end-of-session ritual in `SPEC.md` section 9.3.

### 3.2 Do not

- Do not write Core code unless the student explicitly asks for it. When asked, follow the hint ladder first and confirm the student wants the full solution.
- Do not generate the whole app or whole layers in one go.
- Do not copy the teacher's `nback.c` approach into Swift without explaining what each part does, and what is wrong with it (see `SPEC.md` section 4).
- Do not tick requirements, write test results or write the student's reflection. Those come from the student's own runs and words.
- Do not add libraries, features or abstractions that are not in `SPEC.md`.
- Do not produce code the student has not been given a chance to understand. If the student says "I don't get it", explain again differently, do not move on.

### 3.3 Hint ladder for Core code

When the student is stuck, go one step at a time and stop when they can continue:

1. **Concept**: explain the idea in plain words, with a small example.
2. **Questions**: ask what the function must guarantee and what could go wrong.
3. **Pseudocode**: outline the steps without Swift.
4. **Skeleton**: function signature and `// TODO` comments only.
5. **Review**: the student writes it, the agent reviews and points to problems without fixing them.
6. **Full solution**: only if the student asks for it after the previous steps. Then follow the rule below.

**After a full solution to Core code:** the student closes it and rewrites it from scratch without looking,
then explains it back. The log entry in `docs/LLM_PROCESS.md` marks it as AI-generated.

### 3.4 Teach-back checks

After each Core or Support piece, the agent asks the student to explain it:
- "Walk me through this function with n = 2 and this input."
- "What happens if this line is removed? Which test fails?"
- "Which oral exam question (SPEC section 8) does this answer?"

If the student cannot answer, the piece is not done, whoever wrote it.

---

## 4. Workflow per component

1. **Spec first**: write the component's short entry in `SPEC.md` section 7 (purpose, edge cases, test ideas).
2. **Tests early**: decide which test cases the component needs before or while writing it. Write the test names first.
3. **Code**: write the code in the tier-appropriate way (section 2).
4. **Run**: build and run the tests on your own. Fix failures yourself first.
5. **Break it**: temporarily change the production code so a key test must fail, and check that it does (mutation check). Record it in `docs/TEST_REPORT.md`.
6. **Explain**: teach-back (section 3.4). Fill in the oral exam map (`SPEC.md` section 8).
7. **Log**: update SPEC, `docs/LLM_PROCESS.md`, `docs/TEST_REPORT.md` and `docs/REFLECTION.md` (ritual in `SPEC.md` section 9.3).

---

## 5. Architecture decisions

### 5.1 MVVM layers

| Layer | Contains | Must not |
|---|---|---|
| **Model** | `SequenceGenerator`, per-modality state (`ModalityState`, name TBD), `ScoreCalculator`, plain value types. No SwiftUI, no AVFoundation, no timers | Import SwiftUI, touch the UI, own a timer |
| **ViewModel** | `GameViewModel` (`ObservableObject`, `@Published` state): state machine, round timer, press handling, exposes everything the views display | Navigate between screens, know about layout, draw anything |
| **View** | Home screen, Game screen, grid, match button. Renders state and forwards user actions. Navigation is owned here (or by a coordinator in the view layer) | Contain game rules or timers |
| **Services** | `SpeechService` (`AVSpeechSynthesizer` created once), persistence (settings, scores) | Hold game state |

No class does everything. If a type grows past one clear responsibility, split it.

### 5.2 Design principles

1. **Core logic must be testable without the UI.** Model types are plain Swift with no SwiftUI import. XCTest runs against them directly.
2. **One modality is one unit** (`ModalityState`): own sequence, own current event, own "already pressed" flag, own counts. Basic mode uses one or two instances in the same way, dual n-back uses two. This keeps the dual n-back change small.
3. **The generator decides per event whether it is a match.** For events after the first n: with the chosen probability it copies the value from n steps back, otherwise it picks a value that is explicitly *not* the one from n steps back. The first n events are always non-matches.
4. **The generator takes its own random source** (injected, seedable), not global state. This gives independent sequences for dual n-back and deterministic tests.
5. **The game is an explicit state machine** (`idle`, `running`, `finished`). A match press is only valid in `running`, after event n, and once per event.
6. **The timer is owned by the ViewModel** and cancelled in every exit path: round end, leaving the screen, starting a new round, app backgrounding.
7. **Speech happens after a user gesture** (starting a round), through one `AVSpeechSynthesizer` created once.
8. **Navigation is a view concern.** The ViewModel exposes state such as "round finished"; the view decides what to show.
9. **Feedback is non-offensive**: short colour or scale animation on the button (for example a soft orange pulse), no red, no buzz, no text like "wrong".

### 5.3 Naming

- Types: nouns describing the role (`SequenceGenerator`, `GameViewModel`, `ScoreCalculator`).
- Methods: verbs that describe the effect (`registerMatchPress()`, `advanceToNextEvent()`, `startRound()`).
- Booleans read as questions (`isMatchPressAllowed`, `hasPressedThisEvent`).
- No abbreviations except widely known ones (`n`, `UI`, `TTS`). Avoid `Manager`, `Helper`, `Utils`.
- Constants are named, not magic numbers (`minimumMatchRate`, `maximumMatchRate`, `letterSet`).

### 5.4 Documentation

- Every type and every non-trivial function gets a `///` doc comment: what it does, parameters, return value, important guarantees (for example "the first n events are never matches").
- Comment the **why**, not the **what**. Do not comment obvious lines.
- A comment that mentions a requirement or oral question number is fine (`// D-08: ignore second press on same event`).

### 5.5 Tests

- Framework: XCTest. Test target separate from the app.
- Test names describe the behaviour: `testFirstNEventsAreNeverMatches`, `testSecondPressOnSameEventIsIgnored`.
- Plan: test all five candidates (sequence generation, match-rate enforcement, first-n guarantee, double-press prevention, scoring formula). The lab requires at least three.
- Statistical tests (match rate) run many sequences with a **seeded** random source so they never fail randomly.
- Every key test gets a mutation check (see section 4, step 5).
- Tests assert behaviour, not implementation details.

### 5.6 Other constraints

- Swift and SwiftUI only. No external libraries beyond the platform SDK.
- Small commits, one logical step each, with a descriptive message.
- Keep the build warning-free where reasonable.

---

## 6. Session start prompt (copy this)

> Read `SPEC.md` and `STYLE.md` before anything else. We follow the coding approach in `STYLE.md`:
> my goal is to learn, I write the Core code myself, and you act as tutor and reviewer. Today I want
> to work on: ______. Ask me what I have tried first. At the end of the session, run the ritual in
> `SPEC.md` section 9.3.
