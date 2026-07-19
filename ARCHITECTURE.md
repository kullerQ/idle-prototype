# Architecture (Idle Prototype)

Short map of boot, ownership, and signals. Prefer this over rediscovering `G.initialize`.

## Boot order

1. **Main** (`Scenes/Main/main.tscn`) enters the tree and calls `G.initialize()` (economy + combat only).
2. **Game** (`Scenes/Game/game.tscn`) enters and calls `G.bind_scene_managers($CellManager, $PlayerCellManager)`:
   - Wires scene-placed CellManager / PlayerCellManager
   - Creates TimerManager, BuildingManager, UpgradeManager, LevelUpgradeManager, ExpeditionManager
3. **Game** then parents the remaining runtime nodes (expedition, containers, UIPP/menus).

Editor scene tree ≈ runtime for CellManager / PlayerCellManager (children of `game.tscn`). Other managers are still created in code and `add_child`’d by `Game`.

## Who owns what

| Owner | Responsibility |
|-------|----------------|
| **G** | Service locator + menu/UI event bus. Holds refs; does not parent gameplay nodes. |
| **Game** | Scene hosts CellManager / PlayerCellManager; parents ExpeditionManager, BuildingManager, TimerManager, projectile/particle containers, UIPP/menus. |
| **CellManager** | Resource grid façade: spawn, occupy/free, coords, weights. Composes RefCounted siblings under `Scenes/CellManager/`. Spawn weights from `@export spawn_config` (`Resources/cell_spawn_config.tres`). |
| **CellCombatResolver** | Hit compile, spread damage, kill_grid/kill_cell; emits via CellManager signals. |
| **CellSpecialBehaviors** | Death hooks (lumberjack/outpost/forest) + forest occupy spawn + lumberjack cap. |
| **DruidObeliskSystem** | Obelisk links, buff graph, overheal procs. |
| **PlayerCellManager** | Player tower grid: add towers, highlight, level-up targeting. Injects `manager` / `projectile_manager` onto each `PlayerCell`. |
| **ProjectileManager** | Spawn projectiles; owns projectile scenes/data (e.g. axe `bounce` on `ProjectileData`). Injects `cell_manager` onto each `Projectile` at spawn. Weakening rolls once in `new_projectile` from `ProjectileDataModifiers`. |
| **DamageManager** | Damage compile / stats dictionaries. Helpers: `compile_damage`, `build_projectile_damage`, `new_kill_damage`. |
| **Economy** | Currencies and awards. |
| **UpgradeManager** / **LevelUpgradeManager** | Apply upgrade enums via domain helpers (`_apply_tower_upgrade`, `_apply_wood_upgrade`, `_apply_building_upgrade`, `_apply_projectile_upgrade`). Prefer manager mutators over nested `get_data(...).field` writes. |
| **UpgradeMenu** | Injects `economy` / `upgrade_manager` onto `UpgradeNode`s. |
| **TimerManager** | World timers (spawn ticks, etc.). Owns `cell_manager` ref; spawn timeouts call CellManager façade. |
| **BuildingManager** | Side buildings; injects `economy` onto `BuildingCell`s. UpgradeManager mutates via BuildingManager API only. |
| **ExpeditionManager** | Expedition state; domain signals `expedition_selected` / `started` / `completed` / `ended`. Grid/timer via CellManager + TimerManager façades. |
| **ExpeditionEditor** | Extends CellManager; uses public `cells` / `occupied_cells` / `get_data` / `set_cell_data` only. |
| **ExpeditionMenu** | Injects `ExpeditionManager` onto buttons; closes on `expedition_selected`. |
| **ExpeditionEndScreen** | Opens on `expedition_completed`; calls `manager.end_expedition()` (not raw `G.expedition_manager`). |
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

Gameplay systems should prefer domain signals on their manager (e.g. `expedition_selected` / `started` / `completed` / `ended`) and let UI react—avoid new raw UI emits from combat/expedition code. Menu open/close still goes through `G.open_menu` / `G.close_menu` from UI listeners.

## Remaining static injection (legacy)

Still set at runtime for convenience: `Projectile.particle_container`, `PanelButton.container`, `LevelUpgradeNode.manager`. Prefer explicit `setup` / manager APIs when touching those types.

## Debug input

Cheat / spawn / reload hotkeys in `Scenes/Main/main.gd` run only when `OS.is_debug_build()`. Escape always quits.

## Naming notes

- Player tower scene lives under `Scenes/PlayerCell/` (`class_name PlayerCell`).
- Resource cell data under `Resources/ResourceCells/` (`cell_resource_*.tres`).
- Spawn weights: `CellSpawnConfig` / `CellSpawnTable` / `CellSpawnWeight` in `Resources/`.
