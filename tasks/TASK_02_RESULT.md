# TASK 02 result — Knocking and playable table

## Status
Complete. Godot 4.7.2 parses the project. Headless core tests pass (132 assertions, 0 failures). The placeholder table scene runs headlessly without script errors.

## GDD
Confirmed scoring rules are now in `docs/GDD.md` under **Scoring**. Core code follows those rules and does not invent extra scoring.

## What works
### Knock / pass / mee scoring
- Round stake starts at 1.
- Each knock adds +1 to the current stake before responses.
- PAS pays the current stake immediately and leaves the round.
- MEE stays in for the raised stake and does not pay yet.
- Further knocks in the same round each add another +1.
- Round winner gets 0. Active non-winners at round end pay the final stake.
- 15+ still eliminates. Last remaining player wins the pot.
- Knock is only legal on your turn, before playing a card.

If everyone else PAS after a knock, the knocker wins the round immediately (0 extra points). Passers already paid.

### Playable table
`scenes/table.tscn` is the main scene (placeholder UI only):
- Human at the bottom with clickable hand cards
- 3 AI placeholders with score and card count (hidden cards)
- Central played cards
- Penalty scores
- KLOP when legal
- MEE / PAS when the human must answer a knock
- Placeholder AI: knocks only at stake 1, always MEE, plays the first legal card, never reads hidden hands

## Tests
`tests/run_tests.gd` — 132 passed, including:
1. No knock: non-winners +1, winner 0
2. Knock raises stake 1 → 2
3. PAS pays immediately and leaves
4. MEE does not pay yet
5. Second knock raises stake to 3
6. Round-end active non-winners pay the final stake
7. PAS can eliminate at 15
8. Knock rejected off-turn
9. All PAS: knocker wins
10. Placeholder AI uses only its own legal cards
11. Table session starts and waits for the human

## TODOs still unspecified in the GDD
- Who leads the first round of a later potje
- Deal start position (implemented clockwise from the leader)
- Trick winner if someone already played this trick and then PAS after a later knock (engine prefers still-active followers of the led suit)

## Not in this task
Final art/animation/audio, Avondwinkel, campaign, tutorial, advanced AI, Vuile Was / Witte Was / Toep / Kans op Toep interaction flows.

## Blockers
None for this scope.
