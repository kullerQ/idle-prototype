# Architecture

How the game boots, who owns what, and how systems talk. For naming and “where do I put X”, see [CONVENTIONS.md](CONVENTIONS.md).

---

## Boot order

1. **Main menu** (`ui/main_menu/main_menu.tscn`) — project main scene.
   - **New Game:** delete save, clear pending state → load main scene.
   - **Continue:** load `user://save.json` into `RunState.set_pending()` → load main scene.
2. **Main** (`scenes/main/main.tscn`) — calls `G.initialize()` (economy + combat RefCounted managers).
3. **Game** (`scenes/game/game.tscn`) — child of Main’s SubViewport; calls `G.bind_scene_managers(...)` with scene-placed Node managers.
4. **Main** (deferred) — `RunState.consume_pending()` → `apply_to(...)` if Continue.
5. **Game** — creates projectile/particle containers, UIPP, menus; bridges domain signals to the UI bus.

```text
main_menu
  ├─ New Game  → scenes/main  (fresh)
  └─ Continue  → RunState pending → scenes/main → apply_to

scenes/main
  ├─ G.initialize()
  └─ scenes/game
       ├─ G.bind_scene_managers(CellManager, PlayerCellManager, …)
       ├─ UpgradeManager / LevelUpgradeManager (RefCounted)
       └─ UIPP, menus, domain → UI bridges
```

`G` wires refs; `Game` parents Node managers. Editor tree ≈ runtime for Node managers under `game.tscn`.

---

## Who owns what

| Owner | Role |
|-------|------|
| **G** (`core/g.gd`) | Service locator + menu/tooltip/crit UI bus. No gameplay flags. |
| **RunState / SaveService** | Versioned save dict, menu→session pending handoff, `apply_to` restore. |
| **Game** | Parents Node managers; creates containers/UIPP/menus; bridges `crit_occurred` and tower selection to `G`. |
| **CellManager** | Resource grid: spawn, occupy, combat façade (`features/resource_grid/`). |
| **PlayerCellManager** | Tower grid, highlight, level-up targeting. Domain signals: `tower_pressed`, `level_upgrade_requested`. |
| **ProjectileManager / DamageManager** | Combat spawn and damage compile (`features/combat/`). |
| **UpgradeManager + UpgradeApplier** | Meta upgrades from `data/upgrades/meta/*.tres`. |
| **LevelUpgradeManager + LevelUpgradeApplier** | Per-tower talents from `data/upgrades/level/*.tres`. |
| **ExpeditionManager** | Expedition state (`is_active`), layout load, rewards. |
| **TimerManager / BuildingManager / Economy** | Timers, side buildings, currencies. |
| **UI** (outer) | `ui/main_hud/` — currencies, tooltip, UpgradeMenu, Save button. Sibling of SubViewport in Main. |
| **UIPP** (in-world) | `ui/game_hud/` — crit labels, timer/expedition layout inside Game’s CanvasLayer. |

---

## Signals

### UI bus (via `G`)

Menus: `G.toggle_menu` / `open_menu` / `close_menu`. Tooltips: `tooltip_requested` / `tooltip_close_required`. Crit flash: `crit_label_requested`.

### Domain (preferred for gameplay)

| Emitter | Signal | Consumer |
|---------|--------|----------|
| ExpeditionManager | `expedition_started`, `completed`, … | UI, UIPP |
| ProjectileManager, BuildingManager | `crit_occurred(pos)` | Game → `G.crit_label_requested` → UIPP |
| PlayerCellManager | `tower_pressed`, `level_upgrade_requested` | Game → `G.level_upgrade_menu_*` |
| CellManager | `cell_hitted`, `cell_died`, … | Combat resolver, UI feedback |

Do not emit gameplay events on `G` from grid/combat/building code.

---

## UI split (intentional)

Pixel art renders in a SubViewport. Two HUD layers:

- **Outer UI** — sharp chrome above the scaled view (currencies, tooltips, meta upgrade menu).
- **UIPP** — in-world feedback (crit labels, expedition/timer layout swap).

Shared controls live in `ui/shared/`.

---

## Injection

Containers and deps are passed via `setup()` or assignment from `Game`:

- `Projectile.particle_container` from `ProjectileManager` (set in Game)
- `PlayerCellManager.is_menu_blocking` callback from Game
- Menu deps injected before `_ready` — no `@onready var x = G.x` in leaf menus

No new `static var` DI except `RunState._pending` for menu handoff.

---

## Known stubs

- **Wizard tower** — placeable in data only; no production unlock; attack stub until Magic combat.
- **Expedition rewards** — wood only via `ExpeditionManager.apply_reward`.
- **Expedition time bar** — hidden until time tracking exists.

---

## Testing

```bash
godot --headless -s res://tests/run_tests.gd
```

| Test | Covers |
|------|--------|
| `tests/unit/*` | Damage compile, spawn roll, upgrades, save/load |
| `tests/boot_smoke.gd` | Main scene boots, managers wired |

Debug builds also assert wiring in `G._assert_wired()` at bind time.
