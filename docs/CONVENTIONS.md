# Conventions

Practical rules for this project. Boot and signal details: [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Naming (Godot best practices)

| Kind | Rule | Example |
|------|------|---------|
| Folders | `snake_case` | `features/resource_grid/`, `scenes/main/` |
| Scripts / scenes | `snake_case` | `cell_manager.gd`, `player_cell.tscn` |
| `class_name` | `PascalCase` | `CellManager`, `LevelUpgradeNode` |
| Resource scripts | `_scr_<name>.gd` next to data | `data/resource_cells/_scr_cell_resource_data.gd` |
| Node names in scenes | PascalCase is fine for typed roots | root node `LevelUpgradeNode` in `level_upgrade_node.tscn` |

Co-locate scenes and scripts in the same folder (e.g. `features/towers/player_cell/player_cell.gd` + `player_cell.tscn`).

---

## Where to put new code

| You are adding… | Put it here |
|-----------------|-------------|
| Grid / tower / expedition / building behavior | `features/<domain>/` |
| Pure logic (no Node) | Same feature folder, or `core/` if cross-cutting |
| Stats / unlocks / descriptions | `data/<domain>/` as `.tres` |
| App shell / shared chrome | `ui/` (see UI placement below) |
| Domain-only menu or screen | `features/<domain>/` next to its manager |
| Boot / save / autoload glue | `core/` or `scenes/` |

### UI placement (shell vs domain)

Do **not** put every Control under `ui/`. Split by ownership:

- **`ui/`** — app shell and reusable chrome: main menu, outer HUD (`main_hud/`), in-world HUD host (`game_hud/` / `UIPP`), tooltips, shared controls (`ui/shared/`).
- **`features/<domain>/`** — menus and screens that exist only for that domain and talk to its manager (meta upgrade menu, level upgrade menu, expedition menu / end screen / UI, timer UI). Co-locate with the manager.
- Put a new shared button/panel under `ui/shared/` if two domains would otherwise copy it.
- Do not move a domain menu into `ui/` just because it is a Control node.

### Common tasks

**New meta upgrade** — add `UpgradeDefinition` `.tres` under `data/upgrades/meta/` plus effect script(s) under `data/upgrades/effects/`. Auto-discovered at runtime; no path list to edit.

**New level upgrade** — add `.tres` under `data/upgrades/level/` + effect under `data/upgrades/effects/level/`. Add a `LevelUpgradeNode` instance in `level_upgrade_menu.tscn` with matching `type` export. See frozen scene contract below.

**New projectile** — scene under `features/combat/projectiles/<name>/`, data under `data/projectiles/`, register spawn in `ProjectileManager`.

**New expedition** — JSON + reward `.tres` under `data/expeditions/`; UI under `features/expeditions/`.

---

## Pre-change checklist

Before gameplay or save-format work:

1. **Content** — prefer a `.tres` + effect script under `data/`; do not add description dicts or `_apply_*` match blocks in managers (effects go through appliers).
2. **New manager dependency** — wire from `G.bind_scene_managers` / `scenes/game/game.gd` or the owning manager; do not reach for `G` from combat/grid/building code.
3. **Save format** — extend `RunState`, bump `SAVE_VERSION`, and add/adjust a unit test under `tests/unit/`.
4. **Stubs** — do not build new systems on Wizard combat, non-wood expedition rewards, or the hidden expedition time bar until those stubs are finished ([ARCHITECTURE.md](ARCHITECTURE.md#known-stubs)).
5. **Gate** — run `godot --headless -s res://tests/run_tests.gd` before merging the change.

---

## Documentation comments (`##`)

Godot documentation comments use `##` (not `#`) and appear in the editor Help / inspector tooltips.

Prefer short `##` on:

- Public manager APIs (`setup`, `apply`, save/load, spawn façades)
- Non-obvious invariants (load order, `for_load` skips, injected deps)

Skip restating the function name and skip most private `_` helpers. Keep long narrative in `docs/`.

---

## `G` vs injection vs signals

**Use `G` for:** manager refs, menu open/close, tooltip bus, crit-label bus, boot wiring.

**Do not use `G` for:** gameplay flags, combat/grid logic, tower selection (use `PlayerCellManager` domain signals; `Game` bridges to UI).

**Prefer injection:** `setup()` / fields assigned from `scenes/game/game.gd` or the owning manager.

**Prefer domain signals** for game-world events (`expedition_started`, `tower_pressed`, `crit_occurred`, …). UI may then call `G.open_menu` / `G.close_menu`.

Feature menu scripts (`UpgradeNode`, `LevelUpgradeMenu`, …) may emit tooltip/menu bus signals on `G`. Gameplay managers under `features/` should not.

---

## Upgrades

Both meta and level upgrades use the same data shape:

- `UpgradeDefinition` `.tres` (id, description, effects array)
- Meta effects: `data/upgrades/effects/` → applied by `UpgradeApplier`
- Level effects: `data/upgrades/effects/level/` → applied by `LevelUpgradeApplier` onto a `PlayerCell`

Do not add `_apply_*` match blocks or description dicts in managers.

---

## Save system

- API: `RunState` + `SaveService` in `core/`
- Boot: main menu → `scenes/main` → `RunState.consume_pending()` after bind (Continue only; never auto-load on New Game)
- Extend `RunState` and bump `SAVE_VERSION` when the on-disk format changes
- Never write ad-hoc `user://` files from feature code

| Saved | Not saved (by design) |
|-------|----------------------|
| Economy | Resource grid cells |
| Meta upgrade levels | Building runtime state |
| Tower grid + level upgrades | Timer elapsed / expedition session |

---

## Level upgrade scene contract

`features/towers/level_upgrade_menu/level_upgrade_menu.tscn` uses fixed node names (`Path_0`, `Root`, `ShooterUpgrades`, …). Do not rename or reparent casually — update `level_upgrade_menu.gd` in the same change if you do.

---

## Input and debug

- All keys via **InputMap** in `project.godot` — no hardcoded `KEY_*`
- Debug cheats in `scenes/main/main.gd`, gated with `OS.is_debug_build()`

---

## Tests

Add pure-logic tests under `tests/unit/` (extend `TestCase`). Prefer tests around save round-trips, upgrade apply/load, spawn weights, and damage compile — not UI layout or projectile motion. Register new scripts in `tests/test_runner.gd` `_UNIT_TESTS`. Run all:

```bash
godot --headless -s res://tests/run_tests.gd
```

Expedition JSON format: [data/expeditions/README.md](../data/expeditions/README.md).
