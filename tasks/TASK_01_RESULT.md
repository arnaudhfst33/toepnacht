# TASK 01 result — Core Toepen engine

## Status
Complete. Project parses in Godot 4.7.2. Headless core tests pass (77 assertions, 0 failures).

## What works
Headless rules engine in `scripts/core/`, no UI/art:

- **Cards / deck:** 32 unique cards (4 suits × 8 ranks). Rank order Boer → Vrouw → Heer → Aas → 7 → 8 → 9 → 10. Fisher–Yates shuffle with injectable `RandomNumberGenerator`.
- **Players:** 4 seats (1 human + 3 AI placeholders). Each tracks hand, penalty points, active-in-round, eliminated-in-pot.
- **Deal:** 4 cards each, one at a time, clockwise from the round leader. Human leads the first-ever round; later rounds are led by the previous round winner.
- **Tricks:** Must follow led suit when possible (illegal plays rejected). Highest card of the led suit wins. Trick winner leads the next trick. Winner of the 4th trick wins the round.
- **States:** `DEALING`, `PRE_ROUND_SPECIALS`, `NORMAL_PLAY`, `KNOCK_DECISIONS`, `ROUND_END`, `GAME_END`.
- **Penalties:** Start at 0. `apply_penalty()`; 15+ eliminates. Last remaining player wins the pot (`GAME_END`).
- **Special-hand detection only** (no claim/exchange/bluff flows yet): Toep, Kans op Toep, Vuile Was, Witte Was, Armoede (exactly 14 points, still in the pot).
- **Knock stubs:** `request_knock` / `respond_to_knock` / `resume_after_knock` change state and can mark PAS as inactive. No scoring for klop/pas (GDD unspecified).

## Tests
Runner: `tests/run_tests.gd` + `tests/core_tests.gd`.

Godot 4.7.2 headless:

```text
Godot_v4.7.2-stable_win64_console.exe --headless --path <project> -s res://tests/run_tests.gd
```

Covered (task list + small extras):

1. 32 unique cards  
2. Rank ordering (including Boer weaker than 10)  
3. 4 players receive 4 unique cards  
4. Follow-suit enforcement (illegal card stays in hand)  
5. Highest led-suit card wins (off-suit 10 does not beat hearts)  
6. Fourth-trick winner wins the round  
7. 15 points eliminates; last player wins the pot  
8. Toep detection  
9. Kans op Toep detection  
10. Vuile Was detection  
11. Witte Was detection  
12. Armoede detection  
13. Same RNG seed → same shuffle  

Also: human leads first round; previous round winner leads the next.

## TODOs (unspecified in GDD, not guessed)
- Round-loss penalty amounts, knock stake increases, and PAS/fold scoring.
- Who leads the first round of a later potje (after the first real pot).
- Deal start position (implemented as one-at-a-time clockwise from the leader).
- Whether a player who PAS still plays remaining tricks (currently skipped).

## Not in this task
Final UI/art/audio, Avondwinkel/power-ups, AI strategy, tutorial, campaign map, special-hand *interaction* (claims, re-deal, Kans exchange, bluff).

## Blockers
None for this scope.
