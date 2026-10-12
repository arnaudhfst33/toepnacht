# TASK 02 — Knocking and playable table

## Goal
Build the full knock / continue / pass scoring flow and a minimal playable Godot table using placeholder UI only.

Read `docs/GDD.md` and `AGENTS.md` first. Scoring in the GDD is the source of truth.

## Implement
### Core scoring
- Round stake starts at 1.
- Normal round loss: +1 for each active non-winner.
- Each knock: current round stake += 1.
- PAS after a knock: immediately receive the current stake, leave the round.
- MEE: stay in for the increased stake.
- Further knocks in the same round each add +1 to the stake.
- Round winner: 0 penalty points.
- Active non-winners at round end: final current stake.
- 15 or more penalty points: eliminated. Last remaining player wins the pot.

### Knock flow
- Knock is only legal on your turn, before playing a card.
- Other active players then choose MEE or PAS.
- Support multiple knocks in one round.

### Playable table (placeholder UI)
- Human at the bottom, 3 AI placeholder opponents.
- Show human hand, central played cards, penalty scores.
- KLOP when legal; MEE / PAS when responding to a knock.
- Placeholder AI only (no hidden-card access, no real strategy).

## Tests
Cover at least:
1. No knock: active non-winners get +1, winner 0.
2. Knock raises stake by 1 before responses.
3. PAS pays current stake immediately and leaves the round.
4. MEE does not pay until round end (or a later PAS).
5. A second knock raises the stake by another +1.
6. Round-end active non-winners pay the final stake.
7. PAS can eliminate at 15+.
8. Knock is rejected when it is not that player's turn.

## Do not implement yet
- Final art, animations, audio
- Avondwinkel / power-ups
- Campaign / tutorial
- Advanced AI
- Vuile Was / Witte Was / Toep / Kans op Toep interaction flows

## Completion
- Project parses in Godot.
- Core tests run headlessly and pass.
- Minimal table scene is the runnable main scene.
- Write `tasks/TASK_02_RESULT.md`.
- Do not invent extra rules; TODO anything still unspecified.
