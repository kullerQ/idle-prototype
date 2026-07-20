# Conventions (Idle Prototype)

Team defaults for a 2–3 person Godot project. Follow these before inventing a second place for the same kind of thing.

Companion: [ARCHITECTURE.md](ARCHITECTURE.md) (boot, ownership, signals).

---

## Where do I put…?

| New thing | Put it here |
|-----------|-------------|
| Grid / tower / expedition / building behavior | Matching feature folder under `features/<domain>/` — scene + script together |
| Pure logic with no Node | Same feature folder, or `core/` if truly cross-cutting |
| Tunable numbers / unlocks / descriptions | `data/<domain>/` as `.tres` + `_scr_*.gd`. Meta upgrades: `data/upgrades/meta/` + effect scripts under `data/upgrades/effects/`. Level upgrades: `data/upgrades/level/` + effect scripts under `data/upgrades/effects/level/` |
| Menu / HUD / tooltip | `ui/main_hud/` (outer `UI` + tooltip), `ui/game_hud/` (UIPP, crit labels, button bar), `ui/shared/` (buttons, `NodePopupMenu`), `ui/main_menu/` (boot entry) |
| Cross-feature event that is *not* UI | Emit from the owning manager; UI listens |
| Menu open/close, tooltip, crit-label flash | `G` UI bus only |
| Debug cheats | `Main` + InputMap actions, `OS.is_debug_build()` only |
| Saveable progress | `RunState` + `SaveService` (`core/`) — never ad-hoc `user://` from a random script |

Quick checks:

- **New building type?** → scene/script under `features/buildings/`, data as `.tres` under `data/buildings/`, register/unlock via `BuildingManager` API — not a new field on `G`.
- **New tower / resource cell?** → tower: scene under `features/towers/player_cell/`, data under `data/player_cells/`; resource cell: scene under `features/resource_grid/cell_resource/`, data under `data/resource_cells/`.
- **New projectile?** → scene under `features/combat/projectiles/`, data under `data/projectiles/`, spawn via `ProjectileManager`.
- **New meta upgrade?** → `UpgradeDefinition` `.tres` under `data/upgrades/meta/` + effect Resources under `data/upgrades/effects/`. `UpgradeManager.setup()` auto-discovers all `.tres` in that folder — no path array edits. Effect/id fields use `int` (not manager enums) to avoid `class_name` cycles — same pattern as `CellSpawnWeight`. Do not add match arms in unrelated managers.
- **New level upgrade?** → `UpgradeDefinition` `.tres` under `data/upgrades/level/` + `LevelUpgradeEffect` script(s) under `data/upgrades/effects/level/`. `LevelUpgradeManager.setup()` auto-discovers definitions. Add a matching `LevelUpgradeNode` in the frozen talent-tree scene with the same `type` export (enum int). Do not add `_apply_*` match arms.
- **New expedition?** → layout JSON + reward `.tres` under `data/expeditions/`; runtime/UI under `features/expeditions/`; register via `ExpeditionManager` (not a new field on `G`).
- **New menu?** → `NodePopupMenu` subclass (base under `ui/shared/popup_menu/`); register open/close on `G`; inject manager deps from `Game` / host, not `@onready var x = G.x` in leaf controls when avoidable. Feature-specific menus stay under `features/<domain>/`.
- **New shared button / HUD widget?** → reusable control under `ui/shared/`; outer-chrome under `ui/main_hud/`; in-world HUD under `ui/game_hud/`.

---

## Folder map

| Domain | Home |
|--------|------|
| Boot / autoload / save | `core/` (`g.gd`, `run_state.gd`, `save_service.gd`, `cell_spawn_roll.gd`) + shell scenes (`Scenes/Main/`, `Scenes/Game/`) |
| Main menu | `ui/main_menu/` |
| Resource grid | `features/resource_grid/` + `data/resource_cells/`, `data/spawn/` |
| Towers / level upgrades | `features/towers/` + `data/player_cells/`, `data/upgrades/level/`, `data/upgrades/effects/level/` |
| Combat | `features/combat/` + `data/projectiles/` |
| Economy | `features/economy/` |
| Buildings | `features/buildings/` + `data/buildings/` |
| Expeditions | `features/expeditions/` + `data/expeditions/` |
| Meta upgrades | `features/meta_upgrades/` + `data/upgrades/meta/`, `data/upgrades/effects/` |
| Timers | `features/timers/` |
| Shared UI controls | `ui/shared/` |
| Outer HUD | `ui/main_hud/` |
| In-world HUD | `ui/game_hud/` |
| Tests | `tests/` (`unit/`, `boot_smoke.gd`, `architecture_lint.gd`) |

**Rule:** one domain per PR when moving files. Update `preload` / `res://` paths; open touched scenes once in the editor.

---

## Naming

| Kind | Convention | Example |
|------|------------|---------|
| Files / folders | `snake_case` | `cell_manager.gd`, `player_cell.tscn` |
| `class_name` | `PascalCase` | `CellManager`, `AnimatedButton` |
| Resource scripts | `_scr_<name>.gd` under `data/<domain>/` | `_scr_cell_resource_data.gd` |
| Scene folder ≈ type | Folder name may be PascalCase for editor visibility; script file stays snake_case | `ui/shared/animated_button/animated_button.gd` → `class_name AnimatedButton` |

### Level upgrade scene contract (frozen)

`features/towers/level_upgrade_menu/level_upgrade_menu.tscn` encodes talent-tree layout in node names and hierarchy. Runtime code walks the tree by name — treat these as a **frozen contract** until a data-driven UI redesign:

| Rule | Why |
|------|-----|
| Path branch nodes stay named `Path_0`, `Path_1`, … | `LevelUpgradeMenu.change_path` / `show_upgrade_path` match children with `"Path_%d" % path` |
| Each `Path_*` has a child named `Root` | Path walking does `i.get_node_or_null("Root")` before descending |
| Do **not** rename `ShooterUpgrades`, `RogueUpgrades`, or `DruidUpgrades` | `LevelUpgradeMenu.upgrade_paths` maps `PlayerCellData.Types` → those `$…/UpgradesContainer/*` nodes |
| Do **not** reparent `LevelUpgradeNode` instances casually | `LevelUpgradeNode.path` is set in `_ready` from the **parent** name: `int(get_parent().name.split("_")[1])` — moving a node under a different `Path_*` changes its path index |

If you rename or reparent nodes, update `level_upgrade_menu.gd` and `level_upgrade_node.gd` in the same PR and re-test all three tower trees.

---

## `G` vs injection vs domain signals

### Use `G` for

- Holding top-level manager refs (service locator at this scale).
- Menu open/close (`toggle_menu` / `open_menu` / `close_menu` and the paired signals).
- Tooltip + crit-label UI bus.
- Boot wiring (`initialize`, `bind_scene_managers`).

### Do not use `G` for

- Gameplay flags (prefer the owning manager; e.g. `ExpeditionManager.is_active`).
- Highlight / badge Labels (own on `ButtonContainer` / HUD; inject into consumers).
- Reaching into managers from deep gameplay helpers when a ref can be injected once at setup.
- Parenting gameplay nodes (`Game` parents; `G` wires).
- Emitting crit-label feedback from combat/buildings (emit domain `crit_occurred`; `Game` bridges to the UI bus).
- Tower selection / level-upgrade targeting (`PlayerCellManager` domain signals; `Game` bridges to the UI bus).

### Prefer injection

- `setup` / exported / assigned refs from `Game` or the owning manager.
- Example pattern already in use: `PlayerCellManager` injects into `PlayerCell`; `UpgradeMenu` injects into `UpgradeNode`; `Game` assigns `LevelUpgradeMenu.manager`.

### Prefer domain signals

- Events that mean something in the game world or a system: `expedition_selected` / `started` / `completed` / `ended`, `tower_pressed` / `level_upgrade_requested`, cell hit/kill, tower leveled, etc.
- Owning manager emits; UI (or other domains) connect.
- UI then may call `G.open_menu` / `G.close_menu` — that hop is intentional.

### Allowed `G` reads

- UI shell, composition root (`Main` / `Game`), and debug code.
- Feature menu scripts listed in `tests/architecture_g_allowlist.txt` (tooltip / menu bus only).
- New feature scripts under managers/combat should take injected refs instead of growing `@onready var x = G.x`.

---

## Resources vs code for tunables

| Put in `.tres` / Resource scripts | Keep in GDScript |
|-----------------------------------|------------------|
| Cell / tower / projectile / building stats | One-off glue and orchestration |
| Spawn weights / tables | Tiny constants local to one function |
| Meta + level upgrade definitions + descriptions (`data/upgrades/`) | Manager enums for save compatibility only; no description dicts or `_apply_*` match blocks |

Do not add a second parallel damage Resource path while live combat uses `DamageManager` dictionaries.

---

## Save system

Progress is persisted through `RunState` + `SaveService` (`core/run_state.gd`, `core/save_service.gd`). File: `user://save.json`.

**Boot flow:** `ui/main_menu/main_menu.tscn` (main scene) → New Game or Continue → `Scenes/Main/main.gd` calls `RunState.consume_pending()` after `G.bind_scene_managers` and applies via `RunState.apply_to(...)`. New Game clears any existing save and pending state; Continue loads the file and sets pending before changing scene.

| Saved | Not saved (by design) |
|-------|----------------------|
| Economy (currencies) | Resource grid cells |
| Meta upgrade levels | Building runtime state |
| Tower grid + per-cell level upgrades | Timer elapsed progress |
| | Active expedition session |

After load, the resource grid respawns via `TimerManager` baseline timers — acceptable for the current idle scope.

**Rules:**

- Never write ad-hoc `user://` saves from random scripts.
- New saveable data → extend `RunState.to_dict()` / `from_dict()` and bump `SAVE_VERSION` when the on-disk format changes.
- Debug save/load hotkeys stay in `Main` (`OS.is_debug_build()` only); production uses the main menu.

Press **F5** in the editor to start at the main menu (not directly in-game).

---

## Static injection

**No new `static var` dependency injection.**

Pass containers / managers via `setup()` or instance fields from `Game` / the spawner instead:

- `Projectile.particle_container` — assigned per projectile from `ProjectileManager` (set by `Game`)
- `PanelButton.container` — via `PanelButton.setup(ButtonContainer)`

The only allowed `static var` today is `RunState._pending` (menu → session handoff). `architecture_lint.gd` enforces this.

---

## InputMap

- Gameplay or debug keys → Project Settings **InputMap** actions, then `event.is_action_pressed("…")` / `Input.is_action_just_pressed("…")`.
- Do not add new hardcoded `KEY_*` checks in `main.gd` or the expedition editor.
- Debug actions must still be gated with `OS.is_debug_build()`.

---

## UI layers (intentional split)

Pixel-art games that render through a SubViewport need **two HUD planes**. That split is intentional — do not merge them “for simplicity.”

| Layer | Path | Role |
|-------|------|------|
| Outer `UI` | `ui/main_hud/ui.gd` (node in `Scenes/Main/main.tscn`, sibling of SubViewportContainer) | Shell chrome above the pixel view: currency labels, tooltip host, menus that must not be scaled with the game view |
| Tooltip | `ui/main_hud/tooltip.gd` | Listens to `G` tooltip bus; lives under outer `UI` |
| In-world `UIPP` | `ui/game_hud/uipp.gd` (created under Game’s CanvasLayer) | Crit labels, TimerUI / ExpeditionUI layout swap (base vs expedition) — coordinates match the game SubViewport |
| Button bar | `ui/game_hud/button_container.gd` (child of `game.tscn`) | In-world debug/action buttons + highlight badge ownership |
| Shared controls | `ui/shared/` | `AnimatedButton`, `PanelButton`, `ButtonUpgrades`, `NodePopupMenu` — reusable by any feature menu |

Both HUD layers may listen to `G` UI signals and to expedition domain signals.

### Menu host rule

All `NodePopupMenu` subclasses share one registration style:

1. **Open/close** — base class connects to `G.menu_signals[type]` in `_ready`; callers use `G.toggle_menu` / `open_menu` / `close_menu`.
2. **Deps** — composition root injects managers (`setup()` or fields set before `_ready`). No `@onready var x = G.x` in leaf menus.
3. **Outer host** — `UI` in Main wires `UpgradeMenu` via `register_upgrade_menu` (after `Game.bind_scene_managers` so `upgrade_manager` exists).
4. **In-world host** — `Game` wires `LevelUpgradeMenu`, `ExpeditionMenu`, `ExpeditionEndScreen`, `UIPP`, and `ButtonContainer.setup(...)`.
5. **Leaf controls** — menus inject into `UpgradeNode` / `ExpeditionButton`; those nodes may still emit tooltip bus signals on `G`.

Domain `crit_occurred` is bridged once in `Game` → `G.crit_label_requested` → `UIPP`. Tower selection is bridged once in `Game` between `PlayerCellManager` domain signals and `G.level_upgrade_menu_*`. Do not add parallel crit/tooltip/selection paths.

---

## Checklist for a new feature

1. Pick the domain row in the table above — do not create a sibling “misc” folder.
2. Scene + script co-located; data as `.tres` when numbers/designers care.
3. Public API on the owning manager; mutators for upgrades/economy — no drive-by `get_data().field =` from unrelated systems.
4. Domain signal for non-UI events; `G` only for menu/tooltip/crit bus.
5. Inject deps from `Game` / parent manager; no new statics; no new `G` field unless it is a top-level manager.
6. If it is saveable progress, extend `RunState` — do not invent a one-off save file (see **Save system** above).
7. Pure logic worth locking down? Add a `test_*` method under `tests/unit/` (extends `TestCase`). Run all tests: `godot --headless -s res://tests/run_tests.gd`.

---

## Testing

| What | Where |
|------|-------|
| Headless test runner | `tests/run_tests.gd` |
| Unit tests (pure functions) | `tests/unit/` — damage compile, spawn roll, upgrade applier, run state, save/load |
| Boot smoke (Main + G wiring) | `tests/boot_smoke.gd` |
| Architecture lint | `tests/architecture_lint.gd` — no `G.` under `features/` (except allowlist), no `Scripts/` / `Resources/` folders or path refs, no `static var` outside `core/` |
| Expedition JSON schema | `data/expeditions/README.md` |

Run everything headless from the project root:

```bash
godot --headless -s res://tests/run_tests.gd
```

Exit code `0` = pass, `1` = failure. Prefer extracting testable static helpers (e.g. `CellSpawnRoll.pick_weighted`) over scene-heavy tests at this scale.
