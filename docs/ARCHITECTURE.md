# Architecture (Idle Prototype)

Short map of boot, ownership, and signals. Prefer this over rediscovering `G.initialize`.

**Team rules / where to put code:** [docs/CONVENTIONS.md](CONVENTIONS.md).

---

## Where do I put…?

| New thing | Put it here |
|-----------|-------------|
| Grid / tower / expedition / building behavior | Matching feature folder under `features/<domain>/` — scene + script together |
| Pure logic with no Node | Feature folder, or `core/` if cross-cutting |
| Tunable numbers / unlocks / descriptions | `data/<domain>/` as `.tres` + `_scr_*.gd` |
| Menu / HUD / tooltip | `ui/main_hud/`, `ui/game_hud/`, `ui/shared/`, `ui/main_menu/` |
| Cross-feature event that is *not* UI | Emit from the owning manager; UI listens |
| Menu open/close, tooltip, crit label | `G` UI bus only (combat/buildings emit domain `crit_occurred`; `Game` bridges to the bus) |
| Debug cheats | `Main` + InputMap, `OS.is_debug_build()` only |
| Saveable progress | `RunState` + `SaveService` (`core/`) — not ad-hoc `user://` |

Full folder map, naming, and injection rules: [docs/CONVENTIONS.md](CONVENTIONS.md).

---

## Boot order

1. **MainMenu** (`ui/main_menu/main_menu.tscn`) — project main scene. **New Game** deletes any save and clears pending state; **Continue** loads `user://save.json` into `RunState.set_pending(...)` then changes scene.
2. **Main** (`Scenes/Main/main.tscn`) enters and calls `G.initialize()` (economy + combat RefCounted managers only).
3. **Game** (`Scenes/Game/game.tscn`) enters and calls `G.bind_scene_managers(...)` with scene children:
   - CellManager, PlayerCellManager, TimerManager, BuildingManager, ExpeditionManager
   - Wires deps; creates UpgradeManager / LevelUpgradeManager (RefCounted)
4. **Main** (deferred) calls `RunState.consume_pending()`; if non-null, `RunState.apply_to(...)` restores economy, meta upgrades, and tower grid.
5. **Game** creates projectile/particle containers, UIPP, and menus; bridges domain signals → UI bus (`crit_occurred`, tower selection).

Editor scene tree ≈ runtime for **all Node managers** (children of `game.tscn`). `G` wires; `Game` parents.

```text
MainMenu (run/main_scene)
├── New Game  → SaveService.delete + RunState.clear_pending → Main
└── Continue  → SaveService.load + RunState.set_pending → Main

Main
├── G.initialize()          → Economy, DamageManager, ProjectileManager
└── Game (game.tscn)
    ├── CellManager / PlayerCellManager / TimerManager / BuildingManager / ExpeditionManager
    ├── G.bind_scene_managers(...)  → wire deps + Upgrade* managers
    ├── RunState.consume_pending() → apply_to (Continue only)
    ├── ProjectileContainer / ParticleContainer / UIPP + menus
    ├── crit_occurred → G.crit_label_requested
    └── PlayerCellManager signals → G.level_upgrade_menu_*
```

---

## Who owns what

| Owner | Responsibility |
|-------|----------------|
| **G** | Service locator + menu/tooltip/crit-label UI bus. Holds refs; does **not** parent gameplay nodes or store gameplay flags. |
| **MainMenu** | Boot entry (`ui/main_menu/`): New Game / Continue; sets `RunState` pending before loading Main. |
| **Main** | Shell scene; calls `G.initialize()`; applies pending `RunState` after bind; debug hotkeys only. |
| **Game** | Scene hosts all Node managers; creates containers/UIPP/menus; bridges combat/building crit and tower-selection domain signals to the UI bus. |
| **RunState** / **SaveService** | Save facade (`core/`): versioned dict, pending handoff menu → session, `apply_to` restore entry point. |
| **CellManager** | Resource grid façade: spawn, occupy/free, coords, weights. Lives under `features/resource_grid/`. Holds injected `expedition_manager` / `projectile_manager`. Composes RefCounted siblings (`CellCombatResolver`, `CellSpecialBehaviors`, `DruidObeliskSystem`). |
| **CellCombatResolver** | Hit compile, spread damage, kill_grid/kill_cell; emits via CellManager signals. |
| **CellSpecialBehaviors** | Death hooks (lumberjack/outpost/forest) + forest occupy spawn + lumberjack cap. Uses injected `projectile_manager` (not `G`). |
| **DruidObeliskSystem** | Obelisk links, buff graph, overheal procs. |
| **PlayerCellManager** | Player tower grid under `features/towers/`: add towers, highlight, level-up targeting. Domain signals `tower_pressed`, `level_upgrade_requested`, `tower_selection_cleared`. Injects `manager` / `projectile_manager` onto each `PlayerCell`. Level-up badge label injected from `ButtonContainer`. |
| **ProjectileManager** | Spawn projectiles; domain signal `crit_occurred`. Lives under `features/combat/`. Injects `cell_manager` / `particle_container` onto each `Projectile` at spawn. |
| **DamageManager** | Damage compile / stats dictionaries under `features/combat/`. Helpers: `compile_damage`, `build_projectile_damage`, `new_kill_damage`. |
| **Economy** | Currencies and awards under `features/economy/`. |
| **UpgradeManager** / **UpgradeApplier** | Meta upgrades under `features/meta_upgrades/`. Auto-discovers `data/upgrades/meta/*.tres`; applies via `UpgradeApplier`. |
| **LevelUpgradeManager** / **LevelUpgradeApplier** | Per-tower talent upgrades under `features/towers/`. Auto-discovers `data/upgrades/level/*.tres`; `LevelUpgradeApplier` iterates `LevelUpgradeEffect` resources onto a `PlayerCell`. |
| **UpgradeMenu** | Meta-upgrade UI under `features/meta_upgrades/`; injects `economy` / `upgrade_manager` onto `UpgradeNode`s. Highlight label from `ButtonContainer`. |
| **UI** (outer) | Shell chrome under `ui/main_hud/` (`ui.gd` + `tooltip.gd`), hosted by `Scenes/Main/main.tscn` above the SubViewport. Currencies + tooltip bus listeners. `get_upgrade_menu()` for composition-root access. |
| **UIPP** (in-world) | Game-view HUD under `ui/game_hud/uipp.gd`: crit labels (`label_crit/`), TimerUI / ExpeditionUI layout swap. Created by `Game` under a CanvasLayer. |
| **ButtonContainer** | In-world button bar under `ui/game_hud/button_container.gd` (child of `game.tscn`). Owns upgrades / level-up highlight labels; injects them into `UpgradeMenu` / `PlayerCellManager`. |
| **Shared UI** | `ui/shared/`: `AnimatedButton`, `PanelButton`, `ButtonUpgrades`, `NodePopupMenu` — reused by feature menus. |
| **TimerManager** | World timers under `features/timers/` (with `TimerUI` / `TimerProgressBar`). Holds `cell_manager` + `expedition_manager`; skips auto-start of special spawns while expedition `is_active`. |
| **BuildingManager** | Side buildings under `features/buildings/`; domain signal `crit_occurred`. Injects `economy` onto `BuildingCell`s. Building data under `data/buildings/`. |
| **ExpeditionManager** | Expedition state (`is_active`) under `features/expeditions/`; domain signals `expedition_selected` / `started` / `completed` / `ended`. JSON layouts + `ExpeditionRewardData` under `data/expeditions/` — schema in [data/expeditions/README.md](../data/expeditions/README.md). |
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
| `level_upgrade_menu_*` | LevelUpgradeMenu (fed by `Game` from `PlayerCellManager` domain signals) |
| `tooltip_requested` / `tooltip_close_required` | Tooltip |
| `crit_label_requested` | UIPP (fed by `Game` from domain `crit_occurred`) |
| `ui_layout_change_requested` | UIPP (debug / manual); expeditions use domain signals instead |

### Domain signals (preferred for gameplay)

| Emitter | Signal | Notes |
|---------|--------|-------|
| **ExpeditionManager** | `expedition_selected` / `started` / `completed` / `ended` | UI may then call `G.open_menu` / `close_menu` |
| **ProjectileManager** / **BuildingManager** | `crit_occurred(pos)` | Bridged once in `Game` → `G.crit_label_requested` |
| **CellManager** | `cell_hitted` / `hit_handled` / `cell_died` / … | Grid combat feedback |
| **PlayerCellManager** | `tower_pressed` / `level_upgrade_requested` / `tower_selection_cleared` | Bridged once in `Game` → `G.level_upgrade_menu_*` |

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
- `PlayerCellManager.is_menu_blocking` callback from `Game` (replaces direct `G.opened_menu_type` reads in gameplay)

**No new `static var` dependency injection** (except `RunState._pending` for menu handoff).

---

## Debug input

Cheat / spawn / reload hotkeys use Project Settings **InputMap** actions (see `project.godot` `[input]`). Handled in `Scenes/Main/main.gd` only when `OS.is_debug_build()`. `quit` (Escape) always works. Expedition editor uses `quit` + `editor_save`.

Do not add new hardcoded `KEY_*` checks — add an InputMap action instead.

---

## Naming notes

- Boot: `core/g.gd` autoload, `ui/main_menu/`, `Scenes/Main/`, `Scenes/Game/`.
- Towers: `features/towers/` (`PlayerCellManager`, `PlayerCell`, level-upgrade menu + `LevelUpgradeManager` + `LevelUpgradeApplier`).
- Player cell data under `data/player_cells/` (`player_cell_*.tres` + `_scr_player_cell_data.gd`).
- Level upgrade definitions under `data/upgrades/level/`; effect scripts under `data/upgrades/effects/level/`.
- Resource grid: `features/resource_grid/` (`CellManager`, `CellResource`, combat/specials/druid helpers).
- Resource cell data under `data/resource_cells/` (`cell_resource_*.tres` + `_scr_*.gd`).
- Spawn weights: `CellSpawnConfig` / `CellSpawnTable` / `CellSpawnWeight` under `data/spawn/`.
- Economy: `features/economy/economy.gd`. Combat: `features/combat/` (managers + projectile scenes); projectile `.tres` under `data/projectiles/`.
- Buildings: `features/buildings/` (`BuildingManager`, `BuildingCell`); building `.tres` under `data/buildings/`.
- Timers: `features/timers/` (`TimerManager`, `TimerUI`, `TimerProgressBar`).
- Meta upgrades: `features/meta_upgrades/` (`UpgradeManager`, `UpgradeApplier`, `UpgradeMenu`, `UpgradeNode`); `UpgradeDefinition` + effect Resources under `data/upgrades/meta/` and `data/upgrades/effects/`.
- Expeditions: `features/expeditions/` (`ExpeditionManager`, menu / UI / end screen / editor); JSON layouts + `ExpeditionRewardData` under `data/expeditions/`.
- UI: `ui/shared/` (buttons + `NodePopupMenu`), `ui/main_hud/` (outer `UI` + tooltip), `ui/game_hud/` (`UIPP`, `ButtonContainer`, `LabelCrit`).
- **Wizard tower stub:** `PlayerCellData.Types.WIZARD` and `data/player_cells/player_cell_wizard.tres` remain for internal/layout use only. No production UI or meta upgrade unlocks it; the `debug_add_wizard` hotkey was removed. `wizard_attack()` is a no-op in release builds until Magic combat returns. Expedition rewards go through `ExpeditionManager.apply_reward` (wood only for now).

---

## UI / UIPP split (intentional)

The game renders through a SubViewport. HUD is split on purpose:

| Plane | Lives | Why |
|-------|-------|-----|
| Outer `UI` | Sibling of SubViewportContainer in Main | Chrome that must stay sharp / above the pixel view (currencies, tooltips, UpgradeMenu) |
| In-world `UIPP` | Inside Game (CanvasLayer) | Feedback tied to game-space coords (crit labels) and layout that swaps with expedition state |

Shared leaf controls (`AnimatedButton`, `PanelButton`, `NodePopupMenu`) live under `ui/shared/` and are used by either plane / feature menus.

### Menu host rule

All `NodePopupMenu` subclasses follow the same contract:

| Step | Who | What |
|------|-----|------|
| Open/close routing | `NodePopupMenu._ready` | Connect to the paired signals in `G.menu_signals[type]` |
| Manager deps | Composition root | Inject via `setup(...)` or assigned fields **before** `_ready` — never `@onready var x = G.x` in leaf menus |
| Outer menus | `UI` (Main scene) | `UpgradeMenu` registers with `UI.register_upgrade_menu` in `_enter_tree`; `UI` holds shell refs wired after `Game.bind_scene_managers` |
| In-world menus | `Game` | `LevelUpgradeMenu`, `ExpeditionMenu`, `ExpeditionEndScreen` — assign manager/economy deps in `Game._enter_tree` before or right after `add_child` |
| Highlight badges | `ButtonContainer` | Owns labels; injects into `UpgradeMenu` / `PlayerCellManager` via `setup()` (deferred until `G.ui` exists) |

Leaf controls (`UpgradeNode`, `ExpeditionButton`) receive deps from their menu host's `_inject_*_deps`, not from `G`.

### UI bus bridge (single entry for domain → presentation)

Combat and buildings emit domain `crit_occurred(pos)`. **`Game._on_crit_occurred`** is the only bridge to `G.crit_label_requested`; `UIPP` listens to the bus. Tower selection uses **`Game._wire_tower_selection_bridge`** between `PlayerCellManager` and `G.level_upgrade_menu_*`. Tooltips use `G.tooltip_requested` / `tooltip_close_required` from leaf controls; `Tooltip` listens on the outer UI plane. Do not add second crit/tooltip/selection paths.

---

## Testing

Lightweight checks without a full GUT suite. Run headless from the project root:

```bash
godot --headless -s res://tests/run_tests.gd
```

Exit code `0` = pass, `1` = failure.

| Check | Location | What it covers |
|-------|----------|----------------|
| Unit: damage compile | `tests/unit/test_damage_compile.gd` | `DamageManager.compile_damage` (BASE + BONUS × MULT) |
| Unit: spawn roll | `tests/unit/test_spawn_roll.gd` | `CellSpawnRoll.pick_weighted` |
| Unit: upgrade effect | `tests/unit/test_upgrade_effect.gd` | `UpgradeApplier` + `UpgradeEffectAddProjectileDamage` |
| Unit: level upgrade effect | `tests/unit/test_level_upgrade_effect.gd` | Representative `LevelUpgradeEffect` subclasses |
| Unit: run state / save | `tests/unit/test_run_state.gd`, `test_save_service.gd`, `test_load_bugs.gd` | Save round-trip and known load fixes |
| Boot smoke | `tests/boot_smoke.gd` | Instantiates `Main`, asserts `G` + manager wiring after boot |
| Architecture lint | `tests/architecture_lint.gd` | No stray `G.` in `features/`, no legacy folders/paths, no `static var` outside `core/` |

Add new pure-function tests under `tests/unit/` by extending `TestCase` (`tests/test_case.gd`) with `test_*` methods. Expedition layout JSON schema: [data/expeditions/README.md](../data/expeditions/README.md).

Debug builds still assert wiring in `G._assert_wired()` at bind time — boot smoke catches regressions in CI or before a push.
