# Architecture (Idle Prototype)

Short map of boot, ownership, and signals. Prefer this over rediscovering `G.initialize`.

## Boot order

1. **Main** (`Scenes/Main/main.tscn`) enters the tree and calls `G.initialize()`.
2. **G** (autoload `Scripts/g.gd`) constructs managers and wires deps (economy, damage, cell systems, upgrades, projectiles, expedition).
3. **Game** (`Scenes/Game/game.gd`) parents the scene-based managers under itself and builds UI layers (UIPP, menus, timer UI).

Editor scene tree ≠ runtime tree: managers are created in code, then `add_child`’d by `Game`.

## Who owns what

| Owner | Responsibility |
|-------|----------------|
| **G** | Service locator + menu/UI event bus. Holds refs; does not parent gameplay nodes. |
| **Game** | Runtime scene parenting: CellManager, PlayerCellManager, BuildingManager, TimerManager, ExpeditionManager, projectile/particle containers, UIPP/menus. |
| **CellManager** | Resource grid: spawn, occupy/free, hit resolve, specials, druid obelisks. |
| **PlayerCellManager** | Player tower grid: add towers, highlight, level-up targeting. |
| **ProjectileManager** | Spawn projectiles; owns projectile scenes/data. |
| **DamageManager** | Damage compile / stats dictionaries. |
| **Economy** | Currencies and awards. |
| **UpgradeManager** / **LevelUpgradeManager** | Apply upgrade enums to managers. |
| **TimerManager** | World timers (spawn ticks, etc.). |
| **BuildingManager** | Side buildings (e.g. lumberjack). |
| **ExpeditionManager** | Expedition state; pause/kill grid via CellManager. |
| **UI / UIPP** | Listen to G UI signals; layout swap (base vs expedition). |

## Signal map (via G)

Menus: `toggle_menu` / `open_menu` / `close_menu` → pair of open/close signals per `UI.Menus`.

| Signal | Typical listener |
|--------|------------------|
| `upgrade_menu_*` / `expedition_menu_*` / `expedition_end_*` | UI menus |
| `level_upgrade_menu_*` | LevelUpgradeMenu |
| `tooltip_requested` / `tooltip_close_required` | Tooltip UI |
| `crit_label_requested` | UIPP |
| `cell_hitted` | UI / feedback |
| `player_cell_pressed` | Level-up / selection UI |
| `ui_layout_change_requested` | UIPP |

Gameplay systems should prefer domain signals on their manager (e.g. `expedition_started`) and let UI react—avoid new raw UI emits from combat code.

## Static injection (legacy)

Still set at boot: `PlayerCell.manager` / `.projectile_manager`, `UpgradeNode.economy` / `.upgrade_manager`, `TimerResource.cell_manager`, `Axe.bounce`, `BuildingCell.economy`, `ExpeditionButton.manager`, `Projectile.particle_container`. Prefer explicit `setup` / manager APIs when touching these types (see refactor plan Phase 1).

## Naming notes

- Player tower scene lives under `Scenes/PlayerCell/` (`class_name PlayerCell`).
- Resource cell data under `Resources/ResourceCells/` (`cell_resource_*.tres`).
