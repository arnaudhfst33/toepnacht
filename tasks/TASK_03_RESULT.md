# TASK 03 result — Special rules, baseline AI, tutorials

## Status
Complete. Godot 4.7.2 parses the project. Headless tests pass (132 core + 86 special = 218 assertions, 0 failures). Menu and table scenes run headlessly without script errors.

## GDD updates
- Human leads the first real game; afterwards the previous round winner leads.
- PAS is only a knock response.
- A player who already played in the current trick cannot PAS in that same knock.

## Implemented
### Specials
- **Toep:** declare 4 equal ranks; others +3; new round dealt.
- **Kans op Toep:** swap the off-rank card; completes Toep or continues. No bluff.
- **Vuile Was:** call before the first card; challenge; true = new hand + challenger +1; bluff = caller +1, keeps hand. Unchallenged = believed, caller gets a fresh four-card hand.
- **Witte Was:** same call/challenge flow as Vuile Was (4 pictures).
- **Stock:** discarded/replaced Kans, Vuile Was, and Witte Was cards stay out of the draw stock for the rest of that hand. A new round rebuilds and shuffles the full 32-card deck. Deal is one card at a time clockwise from the round starter.
- **Armoede:** 14/15 announced in state/UI; 15+ eliminates.

### AI
`BaselineAI` uses `PublicView` only (own hand, legal cards, public trick/stake/knock/penalties). Mix of conservative/aggressive play, basic knock and MEE/PAS, deliberate mistakes. No hidden cards. No location personalities.

### Tutorials (placeholder UI)
- Tutorial 1 Blanco Toepen: open cards, predetermined hands, why-tips (ranks, follow suit, tricks, fourth trick, penalties). Player chooses.
- Tutorial 2 Kloppen: open cards, KLOP/MEE/PAS/stake, one scripted AI knock.

Main scene is `scenes/menu.tscn` (Spelen / Tutorial 1 / Tutorial 2).

## Tests
Covered: Toep, Kans success/fail, Vuile/Witte Was true/bluff/unchallenged, discarded Kans cards stay out of stock, new-round full deck, Armoede, first-game lead, previous-winner lead, PAS legality, AI legal cards, AI hidden-card isolation, tutorial scripted states.

## TODOs / ambiguities (not invented)
None remaining for Task 03 specials after the GDD clarifications.

## Not in this task
Final art/audio, shop, campaign map, tutorials 3–7, location AI personalities.

## Blockers
None for this scope.
