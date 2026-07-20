# Idle Prototype

Godot 4.1 idle game prototype. Press **F5** to run — you start at the main menu (`New Game` / `Continue`).

## Project layout

Everything uses **`snake_case` folders and files** ([Godot project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)).

| Folder | What lives here |
|--------|-----------------|
| `core/` | Autoload `G`, save (`RunState`, `SaveService`), shared pure helpers |
| `features/<domain>/` | Gameplay: managers, scenes, scripts co-located by domain |
| `data/<domain>/` | Tunable `.tres` data and `_scr_*.gd` resource scripts |
| `ui/` | App shell chrome (main menu, outer HUD, in-world HUD host, shared controls). Domain menus live under `features/` — see [CONVENTIONS.md](docs/CONVENTIONS.md#ui-placement-shell-vs-domain) |
| `scenes/` | Boot shell only: `main.tscn` (SubViewport + outer UI) and `game.tscn` (managers) |
| `audio/` | Sound files |
| `tests/` | Headless unit tests + boot smoke |
| `docs/` | [CONVENTIONS.md](docs/CONVENTIONS.md) and [ARCHITECTURE.md](docs/ARCHITECTURE.md) |

## Adding something new

1. Pick the domain (`towers`, `combat`, `expeditions`, …).
2. Put behavior in `features/<domain>/` (scene + script together).
3. Put numbers/unlocks in `data/<domain>/` as `.tres`.
4. Wire deps from `scenes/game/game.gd` or the owning manager — not new fields on `G` unless it is a top-level manager.

Details and examples: [docs/CONVENTIONS.md](docs/CONVENTIONS.md).

## Boot flow (short)

```
main_menu → scenes/main → scenes/game
                ↑              ↑
           G.initialize   G.bind_scene_managers
           RunState load  (Continue only)
```

Full sequence: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Save / load

- File: `user://save.json` via `SaveService`
- Saved: economy, meta upgrades, tower grid (+ per-cell level upgrades)
- Not saved: resource grid cells, building runtime state, expedition session
- In-game **Save** button on the outer HUD; **Continue** on the main menu

## Tests

```bash
godot --headless -s res://tests/run_tests.gd
```

Exit code `0` = all passed.

## Docs

- **[CONVENTIONS.md](docs/CONVENTIONS.md)** — naming, where to put code, upgrades, save rules
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** — boot order, who owns what, signals
