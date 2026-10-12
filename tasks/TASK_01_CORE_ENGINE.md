# TASK 01 — Core Toepen Engine

## Goal
Build a headless-testable core Toepen rules engine before final UI or artwork.

Read `docs/GDD.md` and `AGENTS.md` first.

## Implement
### Card model
- 32-card deck.
- Consistent suits.
- Rank order low → high: Boer, Vrouw, Heer, Aas, 7, 8, 9, 10.
- Shuffle supports deterministic seed for tests.

### Players
Initially 4 players:
- 1 human
- 3 AI placeholders

Track:
- hand
- penalty points
- active/inactive in current round
- eliminated/not eliminated in pot

### Deal
- 4 cards per player.
- Deal one card at a time.
- Human starts the first-ever game.
- Winner of previous round leads the next round.

### Trick rules
- 4 tricks per round.
- Must follow led suit when possible.
- Reject illegal plays in core logic.
- Highest card of led suit wins.
- Trick winner leads next trick.
- Winner of fourth trick wins round.

### Game state
Use explicit states for at least dealing, pre-round specials, normal play, knock decisions, round end and game end.

### Penalty/elimination
- Start at 0.
- 15 or more = eliminated.
- Last non-eliminated player wins.

### Detect special hands
Detection only for this task:
- Toep: 4 equal ranks
- Kans op Toep: 3 equal ranks
- Vuile Was: 3 picture cards + one 7
- Witte Was: 4 picture cards
- Armoede: 14/15

Expose clean methods/results so interaction flows can be added later.

## Tests
At minimum:
1. 32 unique cards.
2. Correct rank ordering.
3. 4 players receive 4 cards.
4. Follow-suit enforcement.
5. Highest led-suit card wins.
6. Fourth-trick winner wins round.
7. 15 points eliminates.
8. Toep detection.
9. Kans op Toep detection.
10. Vuile Was detection.
11. Witte Was detection.
12. Armoede detection.
13. Same RNG seed gives same shuffle.

## Do not implement yet
- Final UI/art/animation/audio
- Avondwinkel/power-ups
- Full AI strategy
- Tutorial screens
- Campaign map

## Completion
- Project parses in Godot.
- Core tests run headlessly and pass.
- No known core-rule error in this scope.
- Write `tasks/TASK_01_RESULT.md` with implementation summary, tests and TODOs.
- Do not stop at first error; iterate until validation passes or document a concrete blocker.
