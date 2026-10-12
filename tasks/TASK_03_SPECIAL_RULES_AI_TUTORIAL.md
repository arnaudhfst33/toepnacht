# TASK 03 — Special rules, baseline AI, tutorials 1–2

## Goal
Finish special-rule flows, replace placeholder AI with a simple imperfect baseline, and implement Tutorial 1 (Blanco Toepen) and Tutorial 2 (Kloppen).

Read `docs/GDD.md` and `AGENTS.md` first. Do not invent rules.

## Special rules
Implement from the GDD only:
- Toep: 4 equal ranks, player declares, others +3, redeal. AI may declare.
- Kans op Toep: 3 equal ranks, swap the off-rank card; if Toep then resolve Toep, else continue. No bluff.
- Vuile Was: call before first card; challenge flow; bluff caller +1 keeps hand; true caller new hand, challenger +1.
- Witte Was: detection; only specified flow.
- Armoede: 14/15 announced; 15+ eliminated.

PAS only as knock response. Cannot PAS for a knock if you already played in that trick.

Lead: human first real game; then previous round winner.

## AI
Public info only. Legal cards. Conservative/aggressive mix. Basic knock and MEE/PAS. Deliberate mistakes. No location personalities yet.

## Tutorials
1. Blanco Toepen — open cards, ranks, follow suit, tricks, fourth trick, penalties, predetermined hands, player choices, why-tips.
2. Kloppen — KLOP, MEE/PAS, stake, one scripted knock, open cards.

Placeholder UI only.

## Tests
Toep, Kans success/fail, Vuile Was true/bluff, Witte Was, Armoede, lead rules, PAS legality, AI no hidden cards, AI legal cards, tutorial scripted state.

## Completion
Headless Godot tests + table smoke test. Write `tasks/TASK_03_RESULT.md`.
