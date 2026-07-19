# Architecture (Idle Prototype)

Short map of boot, ownership, and signals. Prefer this over rediscovering `G.initialize`.

**Team rules / where to put code:** [docs/CONVENTIONS.md](docs/CONVENTIONS.md).

---

## Where do I put…?

| New thing | Put it here |
|-----------|-------------|
| Grid / tower / expedition / building behavior | Matching feature folder (`features/<domain>/` when migrated; else `Scenes/<Domain>/`) — scene + script together |
| Pure logic with no Node | Feature folder, or `Scripts/` / `core/` if cross-cutting |
| Tunable numbers / unlocks / descriptions | `data/<domain>/` or `Resources/` (as domains migrate) as `.tres` + `_scr_*.gd` |
| Menu / HUD / tooltip | `ui/main_hud/`, `ui/game_hud/`, `ui/shared/` |
| Cross-feature event that is *not* UI | Emit from the owning manager; UI listens |
| Menu open/close, tooltip, crit label | `G` UI bus only (combat/buildings emit domain `crit_occurred`; `Game` bridges to the bus) |
| Debug cheats | `Main` + InputMap, `OS.is_debug_build()` only |
| Saveable progress | RunState / save API (Phase 5) — not ad-hoc `user://` |

Full folder map, naming, and injection rules: [docs/CONVENTIONS.md](docs/CONVENTIONS.md).

---

## Boot order

1. **Main** (`Scenes/Main/main.tscn`) enters the tree and calls `G.initialize()` (economy + combat RefCounted managers only).
2. **Game** (`Scenes/Game/game.tscn`) enters and calls `G.bind_scene_managers(...)` with scene children:
   - CellManager, PlayerCellManager, TimerManager, BuildingManager, ExpeditionManager
   - Wires deps; creates UpgradeManager / LevelUpgradeManager (RefCounted)
3. **Game** then creates projectile/particle containers, UIPP, and menus; bridges domain `crit_occurred` → `G.crit_label_requested`.

Editor scene tree ≈ runtime for **all Node managers** (children of `game.tscn`). `G` wires; `Game` parents.

```text
Main
├── G.initialize()          → Economy, DamageManager, ProjectileManager
└── Game (game.tscn)
    ├── CellManager / PlayerCellManager / TimerManager / BuildingManager / ExpeditionManager
    ├── G.bind_scene_managers(...)  → wire deps + Upgrade* managers
    ├── ProjectileContainer / ParticleContainer / UIPP + menus
    └── domain crit_occurred → G.crit_label_requested
```

---

## Who owns what

| Owner | Responsibility |
|-------|----------------|
| **G** | Service locator + menu/tooltip/crit-label UI bus. Holds refs; does **not** parent gameplay nodes or store gameplay flags. |
| **Game** | Scene hosts all Node managers; creates containers/UIPP/menus; bridges combat/building crit domain signals to the UI bus. |
| **CellManager** | Resource grid façade: spawn, occupy/free, coords, weights. Lives under `features/resource_grid/`. Holds injected `expedition_manager` / `projectile_manager`. Composes RefCounted siblings (`CellCombatResolver`, `CellSpecialBehaviors`, `DruidObeliskSystem`). |
| **CellCombatResolver** | Hit compile, spread damage, kill_grid/kill_cell; emits via CellManager signals. |
| **CellSpecialBehaviors** | Death hooks (lumberjack/outpost/forest) + forest occupy spawn + lumberjack cap. Uses injected `projectile_manager` (not `G`). |
| **DruidObeliskSystem** | Obelisk links, buff graph, overheal procs. |
| **PlayerCellManager** | Player tower grid under `features/towers/`: add towers, highlight, level-up targeting. Injects `manager` / `projectile_manager` onto each `PlayerCell`. Level-up badge label injected from `ButtonContainer`. |
| **ProjectileManager** | Spawn projectiles; domain signal `crit_occurred`. Lives under `features/combat/`. Injects `cell_manager` / `particle_container` onto each `Projectile` at spawn. |
| **DamageManager** | Damage compile / stats dictionaries under `features/combat/`. Helpers: `compile_damage`, `build_projectile_damage`, `new_kill_damage`. |
| **Economy** | Currencies and awards under `features/economy/`. |
| **UpgradeManager** / **LevelUpgradeManager** | Apply upgrade enums via domain helpers. `UpgradeManager` lives under `features/meta_upgrades/`; `LevelUpgradeManager` under `features/towers/` (holds injected `player_cell_manager`). |
| **UpgradeMenu** | Meta-upgrade UI under `features/meta_upgrades/`; injects `economy` / `upgrade_manager` onto `UpgradeNode`s. Highlight label from `ButtonContainer`. |
| **UI** (outer) | Shell chrome under `ui/main_hud/` (`ui.gd` + `tooltip.gd`), hosted by `Scenes/Main/main.tscn` above the SubViewport. Currencies + tooltip bus listeners. |
| **UIPP** (in-world) | Game-view HUD under `ui/game_hud/uipp.gd`: crit labels (`label_crit/`), TimerUI / ExpeditionUI layout swap. Created by `Game` under a CanvasLayer. |
| **ButtonContainer** | In-world button bar under `ui/game_hud/button_container.gd` (child of `game.tscn`). Owns upgrades / level-up highlight labels; injects them into `UpgradeMenu` / `PlayerCellManager`. |
| **Shared UI** | `ui/shared/`: `AnimatedButton`, `PanelButton`, `ButtonUpgrades`, `NodePopupMenu` — reused by feature menus. |
| **TimerManager** | World timers under `features/timers/` (with `TimerUI` / `TimerProgressBar`). Holds `cell_manager` + `expedition_manager`; skips auto-start of special spawns while expedition `is_active`. |
| **BuildingManager** | Side buildings under `features/buildings/`; domain signal `crit_occurred`. Injects `economy` onto `BuildingCell`s. Building data under `data/buildings/`. |
| **ExpeditionManager** | Expedition state (`is_active`) under `features/expeditions/`; domain signals `expedition_selected` / `started` / `completed` / `ended`. JSON layouts + reward `.tres` under `data/expeditions/`. |
| **ExpeditionEditor** | Extends CellManager under `features/expeditions/expedition_editor/`; uses public `cells` / `occupied_cells` / `get_data` / `set_cell_data` only. |
| **ExpeditionMenu** | Under `features/expeditions/expedition_menu/`; injects `ExpeditionManager` onto buttons; closes on `expedition_selected`. |
| **ExpeditionEndScreen** | Under `features/expeditions/expedition_end_screen/`; opens on `expedition_completed`; calls `manager.end_expedition()`. |

---

## Signal rules

### Via `G` (UI bus only)

Menus: `toggle_menu` / `open_menu` / `close_menu` → pair of open/close signals per `UI.Menus`.

| Signal | Typical listener |
|--------|------------------|
| `upgrade_menu_*` / `expedition_menu_*` / `expedition_end_*` | NodePopupMenu subclasses |
| `level_upgrade_menu_*` | LevelUpgradeMenu |
| `tooltip_requested` / `tooltip_close_required` | Tooltip |
| `crit_label_requested` | UIPP (fed by Game from domain `crit_occurred`) |
| `player_cell_pressed` | Level-up / selection UI |
| `ui_layout_change_requested` | UIPP (debug / manual); expeditions use domain signals instead |

### Domain signals (preferred for gameplay)

| Emitter | Signal | Notes |
|---------|--------|-------|
| **ExpeditionManager** | `expedition_selected` / `started` / `completed` / `ended` | UI may then call `G.open_menu` / `close_menu` |
| **ProjectileManager** / **BuildingManager** | `crit_occurred(pos)` | Bridged once in `Game` → `G.crit_label_requested` |
| **CellManager** | `cell_hitted` / `hit_handled` / `cell_died` / … | Grid combat feedback |

**Do not** emit on `G` from combat/building/grid scripts. **Do not** add gameplay flags on `G` — put them on the owning manager (e.g. `ExpeditionManager.is_active`).

| Use | When |
|-----|------|
| **G** | Menu open/close, tooltip, crit-label bus, holding manager refs |
| **Injection** | Feature scripts need a manager/container — assign from `Game` or parent `setup` |
| **Domain signal** | Something happened in a system and others (often UI) should react |

---

## Injection (no static DI)

Containers and managers are passed via `setup` / assignment from `Game` or the owning manager:

- `ProjectileManager.particle_container` → copied onto each `Projectile` at spawn
- `PanelButton.setup(ButtonContainer)` from `ButtonContainer`
- `CellSpecialBehaviors.projectile_manager` from `CellManager` after bind
- Highlight labels: `ButtonContainer` → `PlayerCellManager` / `UpgradeMenu`

**No new `static var` dependency injection.**

---

## Debug input

Cheat / spawn / reload hotkeys use Project Settings **InputMap** actions (see `project.godot` `[input]`). Handled in `Scenes/Main/main.gd` only when `OS.is_debug_build()`. `quit` (Escape) always works. Expedition editor uses `quit` + `editor_save`.

Do not add new hardcoded `KEY_*` checks — add an InputMap action instead.

---

## Naming notes

- Towers: `features/towers/` (`PlayerCellManager`, `PlayerCell`, level-upgrade menu + `LevelUpgradeManager`).
- Player cell data under `data/player_cells/` (`player_cell_*.tres` + `_scr_player_cell_data.gd`).
- Resource grid: `features/resource_grid/` (`CellManager`, `CellResource`, combat/specials/druid helpers).
- Resource cell data under `data/resource_cells/` (`cell_resource_*.tres` + `_scr_*.gd`).
- Spawn weights: `CellSpawnConfig` / `CellSpawnTable` / `CellSpawnWeight` under `data/spawn/`.
- Economy: `features/economy/economy.gd`. Combat: `features/combat/` (managers + projectile scenes); projectile `.tres` under `data/projectiles/`.
- Buildings: `features/buildings/` (`BuildingManager`, `BuildingCell`); building `.tres` under `data/buildings/`.
- Timers: `features/timers/` (`TimerManager`, `TimerUI`, `TimerProgressBar`).
- Meta upgrades: `features/meta_upgrades/` (`UpgradeManager`, `UpgradeMenu`, `UpgradeNode`); `UpgradeNodeData` script under `data/upgrades/` (Phase 4 will add definition `.tres` here).
- Expeditions: `features/expeditions/` (`ExpeditionManager`, menu / UI / end screen / editor); JSON layouts + `ExpeditionRewardData` under `data/expeditions/`.
- UI: `ui/shared/` (buttons + `NodePopupMenu`), `ui/main_hud/` (outer `UI` + tooltip), `ui/game_hud/` (`UIPP`, `ButtonContainer`, `LabelCrit`).
- Wizard tower remains placeable; attack is a stub until Magic combat returns. Expedition rewards go through `ExpeditionManager.apply_reward` (wood only for now).

---

## UI / UIPP split (intentional)

The game renders through a SubViewport. HUD is split on purpose:

| Plane | Lives | Why |
|-------|-------|-----|
| Outer `UI` | Sibling of SubViewportContainer in Main | Chrome that must stay sharp / above the pixel view (currencies, tooltips, some menus) |
| In-world `UIPP` | Inside Game (CanvasLayer) | Feedback tied to game-space coords (crit labels) and layout that swaps with expedition state |

Shared leaf controls (`AnimatedButton`, `PanelButton`, `NodePopupMenu`) live under `ui/shared/` and are used by either plane / feature menus. Do not put new shared widgets back under `Scenes/`.
