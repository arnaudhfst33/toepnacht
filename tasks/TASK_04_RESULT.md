# TASK 04 result — Studentenhuis campaign, shop, power-ups, save

## Status
Complete. Godot 4.7.2 parses the project. Headless tests pass (132 core + 86 special + 116 campaign = **334** assertions, 0 failures). Menu, table, and Avondwinkel scenes run headlessly without script errors (`--quit-after 2`).

## Files / systems
- `scripts/systems/` — campaign state, economy, shop visit, catalog, power-up service, versioned save, campaign flow
- `scripts/ai/ai_profile.gd` — Studentenhuis potje 1/2/3 and De Huisoudste profiles
- `scenes/shop.tscn`, `scenes/complete.tscn` — placeholder Avondwinkel and location-complete screens
- Menu SPELEN / DOORGAAN; table beer-cap counter, named opponents, 2 power-up slots

## Campaign flow
Studentenhuis potje 1 → Avondwinkel → potje 2 → Avondwinkel → potje 3 (De Huisoudste) → complete and unlock Kroeg.

Loss of any potje resets the run to Studentenhuis potje 1 with 0 beer caps and empty inventory. Tutorial flags and unlocked locations are kept.

Each potje uses a fresh `ToepenGame` (all players 0 penalty).

## Economy
Beer caps are run currency via `Economy` (not UI): round +1, human knock bonus +1, potje +3, human Toep +3, boss +5. Duplicate event keys are ignored. Loss clears caps.

## Power-ups implemented
Kaartje Ruilen (5), Even Spieken (4), Op het Randje (8, passive), Rondje van de Zaak (7), Huisvoordeel (7). Max 2 slots, consumed on successful use.

TODO/unavailable (catalog only, not sold): Wasdag, Dubbel Kloppen, Stalen Zenuwen.

## Save
Version `1` JSON (`user://toepnacht_save.json`). Persists unlocks, Studentenhuis completion, tutorial 1–2 flags, settings defaults, active run (location, potje, caps, inventory), and shop visit offerings so a visit does not reroll.

## Remaining TODOs
- Live mid-hand `ToepenGame` state is not serialized; DOORGAAN from the menu restarts the current potje (caps/inventory/shop are kept).
- Kroeg / Huisfeest / Sociëteit are not playable yet (Kroeg is only unlocked).
- Settings UI is not built; defaults are stored.
- Tutorials 3–7, final art/audio/haptics.
- Headless exit still reports ObjectDB leaks from RefCounted/Callable wiring; tests still exit 0.

## Rule ambiguities (not invented)
- GDD does not define peek display duration; shown to the human until the next round starts or a new peek replaces it. AI never sees it.
- Unchosen Huisvoordeel candidate is inserted at the bottom of the stock (`Deck.return_to_stock_deterministic`).

## Blockers
None for this scope.
