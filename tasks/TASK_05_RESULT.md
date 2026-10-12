# TASK 05 result — Complete campaign, tutorials, power-ups, location AI

## Campaign status
The v1.0 singleplayer campaign is technically playable from Studentenhuis through De Praeses.

Order: Studentenhuis → Kroeg (De Barman) → Huisfeest (De Regelaar) → Sociëteit (De Praeses).

Each location: potje 1 → Avondwinkel → potje 2 → Avondwinkel → boss potje 3.

Loss in any potje resets **that location** to potje 1 (0 beer caps, empty inventory). Unlocks, completed locations, and tutorial flags stay.

Boss victory unlocks the next location. Praeses victory sets campaign complete immediately, shows `TOEPNACHT UITGESPEELD`, and leaves all unlocked locations replayable.

Placeholder location colors/headings distinguish Studentenhuis, Kroeg, Huisfeest, and Sociëteit. Boss names appear on potje 3.

## AI profiles
Shared `BaselineAI` + `AiProfile` parameters (error rate, knock scale, mee/pass chaos, aggression, public-memory weight, was-bluff rate, challenge rate). Public view only: own hand, legal cards, trick, stake, knocks, public played-card keys. No hidden opponent hands.

| Location | Potje 1 | Potje 2 | Boss |
| --- | --- | --- | --- |
| Studentenhuis | high error, timid knocks | moderate | De Huisoudste |
| Kroeg | fewer mistakes | better pass/memory | De Barman (calm, selective) |
| Huisfeest | more aggressive/bluff | varied | De Regelaar (chaotic, imperfect) |
| Sociëteit | high quality | fewer errors | De Praeses (strongest, still `error_rate > 0`) |

Bosses get no extra cards, no rule breaks, no hidden information.

## Tutorial status
1–2 preserved. 3–7 implemented, optional, skippable, replayable, separate from campaign unlocks.

- 3 Bluffen: scripted strong knock then weak/bluff knock; player still chooses
- 4 Was: predetermined true Vuile, bluff, and Witte hands
- 5 Toep / Kans op Toep: four-of-a-kind and triple + off-rank swap (no kans bluff)
- 6 Armoede: human starts at 14
- 7 Avondwinkel: scripted 3 offerings + isolated shop/power-up table (does not mutate the campaign run)

HOE WERKT TOEPEN? lists all seven with completion state.

## Power-up status
All 8 implemented and sold (cost 6 / 5 / 6 for Wasdag / Dubbel Kloppen / Stalen Zenuwen).

Existing five unchanged except catalog now sells the last three.

- **Wasdag**: arm while a human Was claim is being challenged; false claim skips the +1 bluff penalty and consumes; true claim does not consume
- **Dubbel Kloppen**: arm before a legal human KLOP; consume on the knock; +2 extra beer caps if that round is won
- **Stalen Zenuwen**: consume on opponent-knock response; human MEE; if human loses the round, human round penalty −1 (min 0); others unchanged

Illegal activation does not consume. Run loss clears inventory.

## Save migration
Save version **2**. Version 1 loads without reset: `studentenhuis_completed` maps into `completed_locations` and still unlocks Kroeg. New fields: completed locations, campaign complete, tutorials 3–7, armed power-up flags.

Mid-hand `ToepenGame` is still not serialized; DOORGAAN restarts the saved potje (caps, inventory, shop offerings kept).

## Automated tests
132 core + 86 special + 116 campaign + 23 layout + 139 Task 05 = **496 passed**, 0 failed.

Godot 4.7.2 `--headless -s res://tests/run_tests.gd` exits 0.

## Smoke-test status
`--resolution 390x844 --quit-after 2` OK for: menu, table, shop, tutorials, campaign select, complete, settings. Headless still prints ObjectDB/resource leak warnings on some scenes; exit code 0.

DEV location/potje/caps/power-up jumps exist on the campaign screen only when `OS.is_debug_build()`.

## Remaining TODOs
- Serialize live mid-round table state
- Final art, audio, animation, haptics
- ObjectDB leaks on headless quit
- Tutorial 7 table uses an isolated memory campaign so it cannot open the real Avondwinkel scene mid-run; shop teaching is on-table + scripted offerings

## Rule ambiguities (not invented)
- Wasdag timing: activated after a challenge is declared and before resolution; AI challenge of a human claim pauses if Wasdag is held
- Dubbel Kloppen extra caps use economy key `round:loc:potje:serial:dubbel` (does not change stake)
- Stalen Zenuwen reduces only the round-end penalty, not PAS payments

## Technical blockers
None for v1.0 campaign structure.

## Recommended next task
Placeholder audio/haptics pass, or serialize mid-potje table state, or a visual pass that still avoids final pixel art.
