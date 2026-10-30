# LLM process document

## Tools used
- Tool: Google Antigravity CLI (`agy`)
- Model: Claude Opus 4.6 (Thinking)
- Usage: Architecture discussions, code review, boilerplate generation, and spec tracking.

## Context files given
- `docs/SPEC.md`
- `docs/STYLE.md`
- `docs/INITIATE_PROJECT.md`

## Who wrote what
| Component | Written by student | AI-assisted | AI-generated, reviewed by student |
|---|---|---|---|
| Project Skeleton & Folders | | | AI-generated (reviewed by student) |
| `SpeechService.swift` | Adapted from student's TicTacToe `VoiceIO` | AI-assisted (added interruption guard) | |

## Representative prompts
1. **Prompt:** "Start by reading @[docs/INITIATE_PROJECT.md]."
   - **Produced:** Project skeleton matching SPEC and STYLE guidelines (App entry, GameViewModel, Model structs, SpeechService, HomeView, GameView).
   - **Student feedback:** Emphasized simplicity over teacher's bloated VoiceIO; insisted on student's minimalistic VoiceIO pattern.

## What the AI got wrong
1. **Initially drafted audio session setup in SpeechService:** Student corrected agent to maintain strict minimalism modeled after student's clean `VoiceIO` instead of replicating the teacher's unnecessary audio session complexity.

---

## Working log
| Date | Task | What I asked | What I got | What I changed / why | AI mistake? |
|---|---|---|---|---|---|
| 2026-10-30 | Project initialization | Scaffold skeleton from INITIATE_PROJECT.md | Folder layout + files | Enforced student's simple VoiceIO pattern over teacher's complex version | Proposed teacher-like audio session before student reiterated minimalism |
