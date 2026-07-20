# Conventions (Idle Prototype)

Team defaults for a 2–3 person Godot project. Follow these before inventing a second place for the same kind of thing.

Companion: [ARCHITECTURE.md](../ARCHITECTURE.md) (boot, ownership, signals).

---

## Where do I put…?

| New thing | Put it here |
|-----------|-------------|
| Grid / tower / expedition / building behavior | Matching feature folder (migrated: `features/<domain>/`; else `Scenes/<Domain>/`) — scene + script together |
| Pure logic with no Node | Same feature folder, or `Scripts/` / `core/` only if truly cross-cutting |
| Tunable numbers / unlocks / descriptions | `data/<domain>/` when migrated (else `Resources/`) as `.tres` + `_scr_*.gd`. Meta upgrade effects/text: `data/upgrades/` (`UpgradeDefinition` + effect scripts; wood + towers + buildings + projectiles batches done) |
| Menu / HUD / tooltip | `ui/main_hud/` (outer `UI` + tooltip), `ui/game_hud/` (UIPP, crit labels, button bar), `ui/shared/` (buttons, `NodePopupMenu`) |
| Cross-feature event that is *not* UI | Emit from the owning manager; UI listens |
| Menu open/close, tooltip, crit-label flash | `G` UI bus only |
| Debug cheats | `Main` + InputMap actions, `OS.is_debug_build()` only |
| Saveable progress | Through RunState / save API (Phase 5) — never ad-hoc `user://` from a random script |

Quick checks:

- **New building type?** → scene/script under `features/buildings/`, data as `.tres` under `data/buildings/`, register/unlock via `BuildingManager` API — not a new field on `G`.
- **New tower / resource cell?** → tower: scene under `features/towers/player_cell/`, data under `data/player_cells/`; resource cell: scene under `features/resource_grid/cell_resource/`, data under `data/resource_cells/`.
- **New projectile?** → scene under `features/combat/projectiles/`, data under `data/projectiles/`, spawn via `ProjectileManager`.
- **New meta upgrade?** → Prefer `UpgradeDefinition` `.tres` under `data/upgrades/meta/` + effect Resources under `data/upgrades/effects/` (wood + towers + buildings + projectiles batches done this way). Register path in `UpgradeManager._WOOD_DEFINITION_PATHS` / `_TOWER_DEFINITION_PATHS` / `_BUILDING_DEFINITION_PATHS` / `_PROJECTILE_DEFINITION_PATHS`. Effect/id fields use `int` (not manager enums) to avoid `class_name` cycles — same pattern as `CellSpawnWeight`. Do not add match arms in unrelated managers.
- **New expedition?** → layout JSON + reward `.tres` under `data/expeditions/`; runtime/UI under `features/expeditions/`; register via `ExpeditionManager` (not a new field on `G`).
- **New menu?** → `NodePopupMenu` subclass (base under `ui/shared/popup_menu/`); register open/close on `G`; inject manager deps from `Game` / host, not `@onready var x = G.x` in leaf controls when avoidable. Feature-specific menus stay under `features/<domain>/`.
- **New shared button / HUD widget?** → reusable control under `ui/shared/`; outer-chrome under `ui/main_hud/`; in-world HUD under `ui/game_hud/`.

---

## Folder map (current → target)

Phase 3 feature + UI folder moves are done. Remaining physical moves (e.g. `G` → `core/`) wait for later phases. Logical homes:

| Domain | Current home | Target |
|--------|--------------|--------|
| Boot / thin autoload | `Scripts/g.gd`, `Scenes/Main/`, `Scenes/Game/` | `core/` + shell scenes |
| Resource grid | `features/resource_grid/` (+ `data/resource_cells/`, `data/spawn/`) | `features/resource_grid/` |
| Towers / level upgrades | `features/towers/` (+ `data/player_cells/`) | `features/towers/` |
| Combat | `features/combat/` (managers + projectile scenes) | `features/combat/` |
| Economy | `features/economy/` | `features/economy/` |
| Buildings | `features/buildings/` (+ `data/buildings/`) | `features/buildings/` |
| Expeditions | `features/expeditions/` (+ `data/expeditions/`) | `features/expeditions/` |
| Meta upgrades | `features/meta_upgrades/` (+ `data/upgrades/` — `UpgradeDefinition` `.tres` under `meta/`, effect scripts under `effects/`; wood + towers + buildings + projectiles migrated) | `features/meta_upgrades/` |
| Timers | `features/timers/` | `features/timers/` |
| Shared UI controls | `ui/shared/` (`animated_button/`, `panel_button/`, `popup_menu/`) | `ui/shared/` |
| Outer HUD | `ui/main_hud/` (`ui.gd`, `tooltip.gd`; hosted by `Scenes/Main/main.tscn`) | `ui/main_hud/` |
| In-world HUD | `ui/game_hud/` (`uipp.gd`, `button_container.gd`, `label_crit/`) | `ui/game_hud/` |
| Data (`.tres`) | `Resources/` (projectiles in `data/projectiles/`; resource cells in `data/resource_cells/`; spawn in `data/spawn/`; player cells in `data/player_cells/`; buildings in `data/buildings/`; upgrade scripts in `data/upgrades/`; expedition JSON + rewards in `data/expeditions/`) | `data/<domain>/` |

**Rule:** one domain per PR when moving files. Update `preload` / `res://` paths; open touched scenes once in the editor. Do not big-bang rename the tree.

---

## Naming

| Kind | Convention | Example |
|------|------------|---------|
| Files / folders | `snake_case` | `cell_manager.gd`, `player_cell.tscn` |
| `class_name` | `PascalCase` | `CellManager`, `AnimatedButton` |
| Resource scripts | `_scr_<name>.gd` next to or under `data/<domain>/` / `Resources/` | `_scr_cell_resource_data.gd` |
| Scene folder ≈ type | Folder name may be PascalCase for editor visibility; script file stays snake_case | `ui/shared/animated_button/animated_button.gd` → `class_name AnimatedButton` |

Level-upgrade talent trees use a **frozen scene contract**: path nodes named `Path_%d` with nested `Root`. Do not rename those nodes without updating `LevelUpgradeMenu` path-walking code. Prefer data-driven UI when the tree is redesigned (Phase 7).

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

### Prefer injection

- `setup` / exported / assigned refs from `Game` or the owning manager.
- Example pattern already in use: `PlayerCellManager` injects into `PlayerCell`; `UpgradeMenu` injects into `UpgradeNode`; `Game` assigns `LevelUpgradeMenu.manager`.

### Prefer domain signals

- Events that mean something in the game world or a system: `expedition_selected` / `started` / `completed` / `ended`, cell hit/kill, tower leveled, etc.
- Owning manager emits; UI (or other domains) connect.
- UI then may call `G.open_menu` / `G.close_menu` — that hop is intentional.

### Allowed `G` reads

- UI shell, composition root (`Main` / `Game`), and debug code.
- New feature scripts under managers/combat should take injected refs instead of growing `@onready var x = G.x`.

---

## Resources vs code for tunables

| Put in `.tres` / Resource scripts | Keep in GDScript |
|-----------------------------------|------------------|
| Cell / tower / projectile / building stats | One-off glue and orchestration |
| Spawn weights / tables | Tiny constants local to one function |
| Upgrade definitions + descriptions (`data/upgrades/`; wood + towers + buildings + projectiles done) | Temporary enums / description dict only if a new batch is still mid-migration |

Do not add a second parallel damage Resource path while live combat uses `DamageManager` dictionaries. The abandoned `DamageData` / `DamageModData` Resource path was deleted in Phase 1.

---

## Static injection

**No new `static var` dependency injection.**

Pass containers / managers via `setup()` or instance fields from `Game` / the spawner instead:

- `Projectile.particle_container` — assigned per projectile from `ProjectileManager` (set by `Game`)
- `PanelButton.container` — via `PanelButton.setup(ButtonContainer)`

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

### Menu host rule (Phase 6)

All `NodePopupMenu` subclasses share one registration style:

1. **Open/close** — base class connects to `G.menu_signals[type]` in `_ready`; callers use `G.toggle_menu` / `open_menu` / `close_menu`.
2. **Deps** — composition root injects managers (`setup()` or fields set before `_ready`). No `@onready var x = G.x` in leaf menus.
3. **Outer host** — `UI` in Main wires `UpgradeMenu` via `register_upgrade_menu` (after `Game.bind_scene_managers` so `upgrade_manager` exists).
4. **In-world host** — `Game` wires `LevelUpgradeMenu`, `ExpeditionMenu`, `ExpeditionEndScreen`, `UIPP`, and `ButtonContainer.setup(...)`.
5. **Leaf controls** — menus inject into `UpgradeNode` / `ExpeditionButton`; those nodes may still emit tooltip bus signals on `G`.

Domain `crit_occurred` is bridged once in `Game` → `G.crit_label_requested` → `UIPP`. Do not add parallel crit-label paths.

---

## Checklist for a new feature

1. Pick the domain row in the table above — do not create a sibling “misc” folder.
2. Scene + script co-located; data as `.tres` when numbers/designers care.
3. Public API on the owning manager; mutators for upgrades/economy — no drive-by `get_data().field =` from unrelated systems.
4. Domain signal for non-UI events; `G` only for menu/tooltip/crit bus.
5. Inject deps from `Game` / parent manager; no new statics; no new `G` field unless it is a top-level manager.
6. If it is saveable progress, plan for RunState (Phase 5) — do not invent a one-off save file.
|
