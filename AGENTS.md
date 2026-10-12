# AGENTS.md — Toepnacht development rules

You are building Toepnacht in Godot 4.x Standard using GDScript.

## Non-negotiable
1. Read `docs/GDD.md` before changing gameplay.
2. `docs/GDD.md` is the source of truth.
3. Never invent or silently change Toepen rules.
4. If a rule is unspecified, add a clearly named TODO instead of guessing.
5. Do not implement features outside v1.0 unless explicitly requested.
6. Keep core game logic separate from UI/presentation.
7. AI must never access hidden opponent cards.
8. Core rules must be testable without rendering final UI.
9. After each task, run tests and fix errors before completion.

## Preferred structure
- `scripts/core/` pure rules/game state
- `scripts/ai/` AI logic
- `scripts/systems/` campaign/shop/save/economy
- `scripts/ui/` UI controllers
- `scenes/`
- `tests/`
- `assets/`
- `docs/`
- `tasks/`

## Workflow
For each task:
1. Inspect current project.
2. Implement the smallest complete version.
3. Add/update tests.
4. Run Godot headless validation/tests.
5. Fix parse/runtime/test failures.
6. Summarize changes and remaining TODOs.

Use typed GDScript where practical. Prefer clear names and deterministic RNG hooks for tests. Keep save data versioned from the beginning. Use placeholders for art during core-engine work.
