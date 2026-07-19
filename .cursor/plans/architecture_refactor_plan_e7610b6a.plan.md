---
name: Architecture Refactor Plan
overview: "A phased architecture refactor that makes Idle Prototype consistent and navigable for a 2–3 person Godot team: feature-oriented layout, shrink `G` to wiring + UI bus, one pattern per concern, data-driven upgrades/damage cleanup, and a save-ready run-state façade — without over-engineering beyond indie scope."
todos:
  - id: m0-conventions
    content: Write docs/CONVENTIONS.md + expand ARCHITECTURE.md with where-to-put table and G vs domain signal rules
    status: completed
  - id: m1-hygiene
    content: Delete dead DamageData/G.cell_hitted/WIP noise; remove static injection; InputMap; debug asserts on wire
    status: completed
  - id: m2-shrink-g
    content: Move in_expedition to ExpeditionManager; Game parents Node managers; G only wires + UI bus; inject deps into gameplay
    status: completed
  - id: m3-feature-folders
    content: "Migrate domains one PR at a time into features/ + data/ layout (done: economy + combat + resource_grid + towers)"
    status: pending
  - id: m4-upgrade-data
    content: Introduce UpgradeDefinition Resources + appliers; migrate meta then level upgrades off giant match/dicts
    status: pending
  - id: m5-run-state
    content: Add RunState + SaveService façade; apply on boot; serialize IDs/levels not full tres blobs
    status: pending
  - id: m6-ui-ownership
    content: Inject menu deps from composition root; document UI/UIPP split; finish remove-G TODOs
    status: pending
  - id: m7-safety
    content: Add smoke/boot checks and document expedition JSON; optional pure-function tests for damage/spawn/upgrades
    status: pending
isProject: false
---

# Architecture Refactor — Know Where to Put the Next Feature

## Verdict

The game already has the right *shape* (managers, Resources, domain signals, CellManager composition). A prior pass documented in [ARCHITECTURE.md](ARCHITECTURE.md) and the completed [idle_refactor_plan](.cursor/plans/idle_refactor_plan_c3a57792.plan.md) fixed boot opacity and carved up `CellManager`. What still breaks “I know where to put this” is **inconsistent homes for the same kind of thing**, `**G` as god-object + bus + flags**, **dual upgrade/damage models**, and **no conventions doc** that a teammate can follow.

Target: a small-to-medium Godot architecture — **feature folders, scene co-location, thin autoload, domain signals, Resource-backed data** — not a DI framework or enterprise layer cake.

---

## Guiding principles (team of 2–3)

1. **One home per kind of thing** — if two valid places exist, pick one and migrate.
2. **Scene + script together** — Godot’s recommended “assets close to scenes” ([project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)).
3. `**G` is wiring, not gameplay** — composition root + menu/tooltip bus only; gameplay talks through injected managers and domain signals.
4. **Data in Resources, behavior in managers, presentation in UI** — upgrades/descriptions eventually follow the same rule as cell/projectile `.tres`.
5. **Editor tree ≈ runtime tree** for anything you open often (grids, managers that are Nodes).
6. **Abstractions only when it pays rent** — no strategy registries, no second autoload per system, no rewrite of working systems “for purity.”

---

## Target mental model

```mermaid
flowchart TB
  subgraph boot [Boot]
    Main --> G
    Main --> Game
    Main --> OuterUI[UI_outer]
  end
  subgraph core [core]
    G -->|"create + wire"| PureMgrs[RefCounted_managers]
    Game -->|"scene + parent"| NodeMgrs[Node_managers]
  end
  subgraph domains [features]
    ResourceGrid
    Towers
    Combat
    Economy
    Buildings
    Expeditions
    MetaUpgrades
    Timers
  end
  subgraph ui [ui]
    OuterUI
    UIPP
    SharedControls[buttons_tooltip_popup]
  end
  PureMgrs --> domains
  NodeMgrs --> domains
  domains -->|"domain signals"| ui
  ui -->|"menu open/close only"| G
```



**Rule of thumb for new work:**


| New thing                                     | Put it here                                                                 |
| --------------------------------------------- | --------------------------------------------------------------------------- |
| Grid / tower / expedition / building behavior | Matching `features/<domain>/` folder (scene + script)                       |
| Pure logic with no Node                       | `features/<domain>/` or `core/` if truly cross-cutting                      |
| Tunable numbers / unlocks / descriptions      | `data/<domain>/` as `.tres` + `_scr_*.gd`                                   |
| Menu / HUD / tooltip                          | `ui/`                                                                       |
| Cross-feature event that is *not* UI          | Emit from the owning manager; UI listens                                    |
| Debug cheats                                  | `Main` + InputMap actions, `OS.is_debug_build()` only                       |
| Saveable progress                             | Through `RunState` / save API — never ad-hoc `user://` from a random script |


---

## Target folder layout

Keep Godot-friendly co-location; stop the split-brain of “sometimes `Scripts/`, sometimes `Scenes/`, sometimes loose `Resources/`.”

```text
res://
  core/                    # Boot + thin autoload + shared non-feature utils
    g.gd
    run_state.gd           # Serialisable façade (Phase 5)
    displayable_timer.gd
    hit_circle.gd
  features/
    resource_grid/         # CellManager, CellResource, combat/specials/druid helpers
    towers/                # PlayerCell(Manager), level-upgrade UI+logic
    combat/                # Projectile*, DamageManager, ProjectileManager, modifiers
    economy/               # Economy
    buildings/             # BuildingManager, BuildingCell
    expeditions/           # ExpeditionManager, menus, editor, JSON/rewards
    meta_upgrades/         # UpgradeManager, UpgradeMenu, UpgradeNode
    timers/                # TimerManager, TimerUI, TimerProgressBar
  ui/                      # Cross-feature presentation
    main_hud/              # UI (outer), tooltip
    game_hud/              # UIPP, crit labels
    shared/                # AnimatedButton, PanelButton, NodePopupMenu
  data/                    # All .tres + Resource scripts, mirrored by domain
    resource_cells/
    player_cells/
    projectiles/
    buildings/
    expeditions/
    upgrades/              # Future UpgradeEffect / descriptions
    spawn/
  audio/
  docs/                    # ARCHITECTURE.md, CONVENTIONS.md
  Scenes/Main/             # Keep Main as shell OR move under features/shell/
  Scenes/Game/             # Composition root scene
```

**Migration style:** move one domain per PR (update `preload`/`res://` paths, open scenes in editor once to refresh). Do **not** big-bang rename everything in one commit — Godot UID/path churn is painful for 2–3 people.

**Default if you prefer less churn:** keep current `Scenes/` + `Scripts/` + `Resources/` names, but enforce the same *logical* map in [CONVENTIONS.md](docs/CONVENTIONS.md) and only move files when touching that domain. The plan below assumes **gradual physical moves** because your primary goal is navigability.

---

## Current pain (ranked)

1. **No “where to put X” map** — `Scripts/` vs `Scenes/` vs loose Resources; menus split UI/UIPP; managers half in scene, half code-created.
2. `**G` sprawl** (~90+ call sites) — refs + UI bus + `in_expedition` + highlight labels + dead `cell_hitted`.
3. `**UpgradeManager` as cross-domain hub** — giant enum + description dict + match touching six managers ([Scripts/upgrade_manager.gd](Scripts/upgrade_manager.gd)).
4. **Dual systems** — meta upgrades vs level upgrades; live Dictionary damage vs abandoned `DamageData` Resources.
5. **No run persistence** — state scattered across duplicated `.tres`, node levels, instance vars; hard to add idle offline progress later.
6. **Legacy statics** — `Projectile.particle_container`, `PanelButton.container`, mistyped `LevelUpgradeNode.manager`.
7. **WIP noise in type system** — wizard/Magic, expedition rewards, unused test damage mods.
8. **Brittle `$` paths** in level-upgrade menus (acceptable short-term; data-drive when redesigning trees).

---

## Phase 0 — Conventions lock-in (1–2 days)

Ship the rules *before* moving code so both developers share the same defaults.

- Expand [ARCHITECTURE.md](ARCHITECTURE.md) into boot + ownership + signal rules (keep short).
- Add `**docs/CONVENTIONS.md**`: folder map, naming (`snake_case` files, `PascalCase` `class_name`, folder = feature), when to use `G` vs injection vs domain signals, InputMap for new keys, Resource vs code for tunables, “no new static injection.”
- Add a one-page **“Where do I put…?”** table (copy of the table above).
- Align naming leftovers: folder/file mismatches (`ButtonAnimated` → `animated_button` is fine if documented; fix mistyped static on `LevelUpgradeNode`).

**Done when:** a new teammate can answer “where does a new building type go?” from docs alone.

---

## Phase 1 — Hygiene and delete dual models (2–3 days)

Cheap consistency; reduces cognitive load before moves.


| Action                                          | Detail                                                                                                                                 |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Remove dead bus signal                          | `G.cell_hitted` — unused; real path is `CellManager.cell_hitted`                                                                       |
| Delete or quarantine abandoned damage Resources | `Resources/_scr_damage_data.gd`, `_scr_damage_mod.gd`, `DamageModData/test_mod_*` unless you commit to migrating *to* them in Phase 4  |
| Finish or strip WIP surfaces                    | Wizard/`Magic` / expedition reward: either minimal working stub behind one API, or remove from enums/registries until real work starts |
| Kill remaining statics                          | Inject `particle_container` / button `container` via `setup()` from `Game`; delete `LevelUpgradeNode.manager` static                   |
| InputMap                                        | Move debug/Escape bindings from hardcoded `KEY_*` in [main.gd](Scenes/Main/main.gd) to project InputMap actions                        |
| Assert wiring                                   | After `bind_scene_managers`, assert required refs non-null (debug builds) so init-order bugs fail loudly                               |


**Decision (concrete):** keep **live `DamageManager` dictionaries** for now; **delete abandoned DamageData path**. Revisit Resource damage only if combat balance tooling needs editor-visible mods.

---

## Phase 2 — Shrink `G` and unify composition (3–5 days)

This is the biggest “understandability” win.

### 2.1 What `G` may keep

- Creating / holding refs to managers (service locator — fine at this scale)
- Menu open/close + tooltip + crit-label **UI bus** (one place for popups)
- `toggle_menu` / `open_menu` / `close_menu`

### 2.2 What leaves `G`


| Leave                                           | Move to                                                                                                         |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `in_expedition`                                 | `ExpeditionManager.is_active` (CellManager/TimerManager ask expedition or receive a bool/callback at wire time) |
| `opened_menu_type`                              | Stay on a small `MenuRouter` *or* remain on G if menus stay — prefer keep on G until UI phase                   |
| Highlight labels                                | Owning UI (`ButtonContainer` / HUD), not G                                                                      |
| Gameplay → `G.crit_label_requested` from combat | Prefer domain signal on combat/UI bridge wired once in `Game`                                                   |


### 2.3 One manager placement rule

**Chosen rule:** Node managers that you debug in-editor live as children of [game.tscn](Scenes/Game/game.tscn) (already true for Cell/PlayerCell). Extend to **TimerManager, BuildingManager, ExpeditionManager** as scene children (or `@export` PackedScenes instantiated in `Game._enter_tree` only — not in `G`).

`G` **wires**; `Game` **parents**. Stop creating PackedScenes inside [g.gd](Scripts/g.gd) (`TIMER_MANAGER_SCENE` / `BUILDING_MANAGER_SCENE` move to `Game`).

RefCounted managers (`Economy`, `DamageManager`, `ProjectileManager`, `UpgradeManager`, `LevelUpgradeManager`) stay created in `G.initialize` / bind — they have no Node presence.

### 2.4 Injection discipline

- Prefer constructor/`setup` / exported refs set by `Game` over `@onready var x = G.x` in feature scripts.
- Allow `G` reads in **UI shell** and **debug** only; gameplay managers should not call `G.projectile_manager` (e.g. [cell_special_behaviors.gd](features/resource_grid/cell_special_behaviors.gd) should use injected refs).

**Done when:** reading `g.gd` fits on one screen of responsibilities; new gameplay feature does not need a new field on `G` unless it is a top-level manager.

---

## Phase 3 — Feature-folder migration (1–2 weeks, domain-by-domain)

Migrate in this order (dependency-friendly):

1. ~~`economy` + `combat`~~ (done → `features/economy/`, `features/combat/`, `data/projectiles/`)
2. ~~`resource_grid`~~ (done → `features/resource_grid/`, `data/resource_cells/`, `data/spawn/`)
3. ~~`towers` + level upgrades~~ (done → `features/towers/`, `data/player_cells/`)
4. `buildings` + `timers`
5. `meta_upgrades`
6. `expeditions` (incl. editor + JSON under `data/expeditions/`)
7. `ui/shared` + HUD split documented

After each domain: update [ARCHITECTURE.md](ARCHITECTURE.md) ownership table; smoke-test main loop + expedition editor.

**Do not** rename `class_name`s unless necessary — path moves are enough.

---

## Phase 4 — Upgrades become data-driven (1–2 weeks)

Today both upgrade systems are **code enums + string dicts + match**. That does not scale and duplicates concepts (crit, cooldown, projectile stats).

### Target pattern

```text
data/upgrades/meta/upgrade_shooter_crit.tres   # UpgradeDefinition Resource
features/meta_upgrades/upgrade_applier.gd      # Applies typed effects to manager APIs
```

- `UpgradeDefinition`: id, cost, description, prerequisites, **effect list** (Resource effects: `ModifyTowerStat`, `UnlockCellType`, `ModifyProjectileStat`, …).
- `UpgradeManager.purchase(def)` applies effects via **existing manager mutator APIs** (already partially grouped in `_apply_*_upgrade` helpers) — do not scatter `get_data().field =` again.
- Level upgrades: same `UpgradeDefinition` shape, scoped to `PlayerCell` instance; UI can keep scene trees short-term, but **effect + text** leave GDScript dicts.
- Shared description/effect types between meta and level where stats overlap.

**Migration:** convert upgrades in batches (wood → towers → buildings → projectiles). Keep enum IDs as `UpgradeDefinition.id` during transition if menus still key off enums.

**Done when:** adding a new +10% crit upgrade is “new `.tres` + maybe one effect type if missing” — not a new `match` arm and string in two managers.

---

## Phase 5 — RunState + save façade (3–5 days)

Idle games need this before more economy/expedition features, or you will paint yourself into a corner.

```mermaid
flowchart LR
  RunState --> Economy
  RunState --> MetaUpgradeLevels
  RunState --> TowerInstances
  RunState --> Unlocks
  SaveService -->|"user://save.json"| RunState
  RunState -->|"apply_to"| Managers
```



- Introduce `core/run_state.gd` (Dictionary or Resource) capturing: currencies, purchased meta upgrades, tower grid state, unlocks, expedition progress flags.
- `SaveService` load/save `user://`; `Game` applies RunState → managers on boot / new game.
- **Do not** serialize full duplicated `.tres` blobs — serialize IDs + levels + instance overrides.
- Wire autosave on meaningful events (upgrade purchased, expedition end) later; façade first.

This forces clearer ownership: if state isn’t on RunState or a manager API, it shouldn’t be “progress.”

---

## Phase 6 — UI ownership cleanup (3–5 days)

- Document the intentional **two-layer HUD** (outer `UI` over SubViewport vs in-world `UIPP`) in ARCHITECTURE — it is valid for pixel-art SubViewport setups.
- **One menu host rule:** all `NodePopupMenu` subclasses registered the same way (signals via G menu router; deps injected by host, not `@onready G.`*).
- Finish TODOs in [ui.gd](Scenes/Main/ui.gd) / [upgrade_menu.gd](Scenes/UpgradeMenu/upgrade_menu.gd) (“remove G dependency”) via injection from Main/Game.
- Crit labels / tooltips: listen to a single UI-facing signal source wired in composition root.

Optional later: extract `MenuRouter` from `G` if `g.gd` is still noisy — only after Phase 2.

---

## Phase 7 — Softening brittle UI structure (as needed)

When you next redesign talent trees:

- Replace name-parsed paths (`Path_%d`, `split("_")`) with explicit `@export` refs or UpgradeDefinition-driven UI builder.
- Until then: treat level-upgrade scene hierarchy as **frozen contract**; document it in CONVENTIONS.

No big rewrite required for architecture health if Phase 4 moves logic out of the scene.

---

## Phase 8 — Lightweight safety net (ongoing)

At this scale, full GUT suite is optional; add **high-ROI checks** only:

- Pure functions: damage compile, spawn weight roll, upgrade effect apply — unit-testable without scenes.
- One “boot smoke” that instantiates Main and asserts managers non-null (can be editor script or GUT later).
- Keep expedition JSON schema documented next to `data/expeditions/`.

---

## Explicit non-goals (avoid over-scope)

- Replacing `G` with a DI container or 8 autoloads
- Rewriting combat to ECS
- Forcing all managers to be Nodes or all to be RefCounted
- Pixel-perfect UI redesign unrelated to ownership
- Committing gitignored `.dev/` analysis as-is — fold useful bits into `docs/` instead

---

## Suggested PR / milestone order


| Milestone            | Outcome                                                |
| -------------------- | ------------------------------------------------------ |
| M0 Conventions       | Docs + team agreement                                  |
| M1 Hygiene           | Dead code gone; statics gone; InputMap                 |
| M2 Composition       | `G` thin; Game parents Node managers; flags on domains |
| M3 Folders           | 1–2 domains moved per PR until layout matches map      |
| M4 Upgrades-as-data  | New upgrades are `.tres`                               |
| M5 Save façade       | Load/save round-trip of core progress                  |
| M6 UI injection      | Menus don’t poke `G` for managers                      |
| M7 Tests/docs polish | Smoke + updated ARCHITECTURE                           |


---

## How you’ll know it worked

- New feature checklist takes < 2 minutes: domain folder → data `.tres` → manager API → UI listen to domain signal.
- `G.` grep shrinks mostly to UI/boot/debug.
- Editor `game.tscn` shows the gameplay systems you care about.
- Adding an upgrade does not require editing a 200-line `match`.
- Both developers give the same answer to “where does X go?”

