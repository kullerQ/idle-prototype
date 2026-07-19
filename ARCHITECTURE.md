# Architecture (Idle Prototype)

Short map of boot, ownership, and signals. Prefer this over rediscovering `G.initialize`.

## Boot order

1. **Main** (`Scenes/Main/main.tscn`) enters the tree and calls `G.initialize()`.
2. **G** (autoload `Scripts/g.gd`) constructs managers and wires deps via named helpers:
   - `_create_economy()` → `_create_combat()` → `_create_cell_systems()` → `_wire_upgrades()` → `_wire_expedition()`
3. **Game** (`Scenes/Game/game.gd`) parents the scene-based managers under itself and builds UI layers (UIPP, menus, timer UI). See the runtime-tree comment at the top of `game.gd`.

Editor scene tree ≠ runtime tree: managers are created in code, then `add_child`’d by `Game`.

## Who owns what

| Owner | Responsibility |
|-------|----------------|
| **G** | Service locator + menu/UI event bus. Holds refs; does not parent gameplay nodes. |
| **Game** | Runtime scene parenting: CellManager, PlayerCellManager, BuildingManager, TimerManager, ExpeditionManager, projectile/particle containers, UIPP/menus. |
| **CellManager** | Resource grid façade: spawn, occupy/free, coords, weights. Composes RefCounted siblings under `Scenes/CellManager/`. |
| **CellCombatResolver** | Hit compile, spread damage, kill_grid/kill_cell; emits via CellManager signals. |
| **CellSpecialBehaviors** | Death hooks (lumberjack/outpost/forest) + forest occupy spawn + lumberjack cap. |
| **DruidObeliskSystem** | Obelisk links, buff graph, overheal procs. |
| **PlayerCellManager** | Player tower grid: add towers, highlight, level-up targeting. Injects `manager` / `projectile_manager` onto each `PlayerCell`. |
| **ProjectileManager** | Spawn projectiles; owns projectile scenes/data (e.g. axe `bounce` on `ProjectileData`). |
| **DamageManager** | Damage compile / stats dictionaries. |
| **Economy** | Currencies and awards. |
| **UpgradeManager** / **LevelUpgradeManager** | Apply upgrade enums via domain helpers (`_apply_tower_upgrade`, `_apply_wood_upgrade`, `_apply_building_upgrade`, `_apply_projectile_upgrade`). Prefer manager mutators over nested `get_data(...).field` writes. |
| **UpgradeMenu** | Injects `economy` / `upgrade_manager` onto `UpgradeNode`s. |
| **TimerManager** | World timers (spawn ticks, etc.). Pass `CellManager` into `TimerResource` when creating one. |
| **BuildingManager** | Side buildings; injects `economy` onto `BuildingCell`s. |
| **ExpeditionManager** | Expedition state; domain signals `expedition_started` / `expedition_ended`. |
| **ExpeditionMenu** | Injects `ExpeditionManager` onto `ExpeditionButton`s. |
| **UI / UIPP** | Listen to G UI signals + expedition domain signals; layout swap (base vs expedition). |

## Signal map (via G)

Menus: `toggle_menu` / `open_menu` / `close_menu` → pair of open/close signals per `UI.Menus`.

| Signal | Typical listener |
|--------|------------------|
| `upgrade_menu_*` / `expedition_menu_*` / `expedition_end_*` | NodePopupMenu subclasses |
| `level_upgrade_menu_*` | LevelUpgradeMenu |
| `tooltip_requested` / `tooltip_close_required` | Tooltip |
| `crit_label_requested` | UIPP |
| `cell_hitted` | UI / feedback |
| `player_cell_pressed` | Level-up / selection UI |
| `ui_layout_change_requested` | UIPP (debug / manual); expeditions use domain signals instead |

Gameplay systems should prefer domain signals on their manager (e.g. `expedition_started` / `expedition_ended`) and let UI react—avoid new raw UI emits from combat code.

## Remaining static injection (legacy)

Still set at runtime for convenience: `Projectile.particle_container`, `PanelButton.container`, `LevelUpgradeNode.manager`. Prefer explicit `setup` / manager APIs when touching those types.

## Naming notes

- Player tower scene lives under `Scenes/PlayerCell/` (`class_name PlayerCell`).
- Resource cell data under `Resources/ResourceCells/` (`cell_resource_*.tres`).
