# Conventions (Idle Prototype)

Team defaults for a 2–3 person Godot project. Follow these before inventing a second place for the same kind of thing.

Companion: [ARCHITECTURE.md](../ARCHITECTURE.md) (boot, ownership, signals).

---

## Where do I put…?

| New thing | Put it here |
|-----------|-------------|
| Grid / tower / expedition / building behavior | Matching feature folder (today: `Scenes/<Domain>/`; target: `features/<domain>/`) — scene + script together |
| Pure logic with no Node | Same feature folder, or `Scripts/` / `core/` only if truly cross-cutting |
| Tunable numbers / unlocks / descriptions | `Resources/` (target: `data/<domain>/`) as `.tres` + `_scr_*.gd` |
| Menu / HUD / tooltip | Outer `UI` / in-world `UIPP` / shared controls under `Scenes/` (target: `ui/`) |
| Cross-feature event that is *not* UI | Emit from the owning manager; UI listens |
| Menu open/close, tooltip, crit-label flash | `G` UI bus only |
| Debug cheats | `Main` + InputMap actions, `OS.is_debug_build()` only |
| Saveable progress | Through RunState / save API (Phase 5) — never ad-hoc `user://` from a random script |

Quick checks:

- **New building type?** → building scene/script next to `BuildingManager` / `BuildingCell`, data as `.tres` under `Resources/`, register/unlock via `BuildingManager` API — not a new field on `G`.
- **New tower / resource cell?** → `PlayerCell` / `CellResource` scene + `Resources/PlayerCells/` or `Resources/ResourceCells/` data.
- **New projectile?** → scene under `features/combat/projectiles/`, data under `data/projectiles/`, spawn via `ProjectileManager`.
- **New meta upgrade?** → today: enum + apply helper on `UpgradeManager` (Phase 4: `.tres` under upgrades data). Do not add match arms in unrelated managers.
- **New menu?** → `NodePopupMenu` subclass; register open/close on `G`; inject manager deps from `Game` / host, not `@onready var x = G.x` in leaf controls when avoidable.

---

## Folder map (current → target)

Physical moves happen domain-by-domain (Phase 3). Until then, **logical** homes match this map even if paths still say `Scenes/` / `Scripts/` / `Resources/`.

| Domain | Current home | Target |
|--------|--------------|--------|
| Boot / thin autoload | `Scripts/g.gd`, `Scenes/Main/`, `Scenes/Game/` | `core/` + shell scenes |
| Resource grid | `Scenes/CellManager/`, `Scenes/CellResource/` | `features/resource_grid/` |
| Towers / level upgrades | `Scenes/PlayerCell*`, `Scenes/LevelUpgradeMenu/`, `Scripts/level_upgrade_manager.gd` | `features/towers/` |
| Combat | `features/combat/` (managers + projectile scenes) | `features/combat/` |
| Economy | `features/economy/` | `features/economy/` |
| Buildings | `Scenes/BuildingManager/`, `Scenes/BuildingCell/` | `features/buildings/` |
| Expeditions | `Scripts/expedition_manager.gd`, `Scenes/Expedition*` | `features/expeditions/` |
| Meta upgrades | `Scripts/upgrade_manager.gd`, `Scenes/UpgradeMenu/`, `Scenes/UpgradeNode/` | `features/meta_upgrades/` |
| Timers | `Scenes/TimerManager/`, `Scenes/TimerUI/` | `features/timers/` |
| Shared UI controls | `Scenes/ButtonAnimated/`, `Scenes/ButtonPanel/`, popup helpers | `ui/shared/` |
| Data (`.tres`) | `Resources/` (projectiles already in `data/projectiles/`) | `data/<domain>/` |

**Rule:** one domain per PR when moving files. Update `preload` / `res://` paths; open touched scenes once in the editor. Do not big-bang rename the tree.

---

## Naming

| Kind | Convention | Example |
|------|------------|---------|
| Files / folders | `snake_case` | `cell_manager.gd`, `player_cell.tscn` |
| `class_name` | `PascalCase` | `CellManager`, `AnimatedButton` |
| Resource scripts | `_scr_<name>.gd` next to or under `Resources/` | `_scr_player_cell_data.gd` |
| Scene folder ≈ type | Folder name may be PascalCase for editor visibility; script file stays snake_case | `Scenes/ButtonAnimated/animated_button.gd` → `class_name AnimatedButton` |

Known leftover (documented, not urgent to rename):

- Folder `Scenes/ButtonAnimated/` holds `animated_button.gd` / `.tscn` (`AnimatedButton`). Prefer the file name when searching; do not invent a second control type.

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
| Future upgrade definitions + descriptions (Phase 4) | Temporary enums during migration |

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

| Layer | Role |
|-------|------|
| `UI` (outer, over SubViewport) | Shell chrome, menus that sit above the pixel view |
| `UIPP` (inside game view) | In-world HUD, crit labels, layout swap (base vs expedition) |

Both may listen to `G` UI signals and to expedition domain signals. Prefer one registration style for all `NodePopupMenu` subclasses (Phase 6).

---

## Checklist for a new feature

1. Pick the domain row in the table above — do not create a sibling “misc” folder.
2. Scene + script co-located; data as `.tres` when numbers/designers care.
3. Public API on the owning manager; mutators for upgrades/economy — no drive-by `get_data().field =` from unrelated systems.
4. Domain signal for non-UI events; `G` only for menu/tooltip/crit bus.
5. Inject deps from `Game` / parent manager; no new statics; no new `G` field unless it is a top-level manager.
6. If it is saveable progress, plan for RunState (Phase 5) — do not invent a one-off save file.
|
