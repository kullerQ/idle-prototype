# Expedition data

Layout files and reward Resources for `ExpeditionManager`. Runtime code lives under `features/expeditions/`.

---

## File naming

| Kind | Pattern | Example |
|------|---------|---------|
| Layout JSON | `{type_lowercase}_{level}.json` | `white_tree_1.json` |
| Reward `.tres` | `expedition_reward_{name}.tres` | `expedition_reward_forest.tres` |

`ExpeditionManager.get_expedition_path(type, level)` builds the JSON path from the enum key (`Types.WHITE_TREE` → `white_tree`) and level.

Register new expedition types in `ExpeditionManager.Types` and map rewards in `ExpeditionManager.REWARD_DATA`.

---

## Layout JSON schema

Top-level object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `goal` | int | yes | `ExpeditionManager.Goals` value (see below) |
| `cells` | array | yes | All placed cells for the layout (may be empty) |
| `target_cells` | array | when `goal` is BREAK_TARGETS | Subset of cells that must be destroyed to win |

Each cell entry (`cells` and `target_cells`):

| Field | Type | Description |
|-------|------|-------------|
| `name` | int | `CellManager.Names` value (e.g. `1` = WOOD_TREE, `5` = SPECIAL_DRUID_OBELISK) |
| `x` | int | Grid column (0-based, matches `CellManager` coords) |
| `y` | int | Grid row (0-based) |

### Goal values (`ExpeditionManager.Goals`)

| Value | Name | Win condition |
|-------|------|---------------|
| `1` | FULL_CLEAR | Reduce total grid HP to 0 (every occupied cell cleared) |
| `2` | BREAK_TARGETS | Destroy every cell listed in `target_cells` |

For `FULL_CLEAR`, populate `cells` only; `target_cells` may be omitted or empty.

For `BREAK_TARGETS`, place the full layout in `cells` and mark objectives in `target_cells` (same `{name, x, y}` shape). The expedition editor writes targets when a cell is flagged as a target.

---

## Example (`white_tree_1.json`)

```json
{
  "cells": [
    {"name": 5, "x": 5, "y": 1},
    {"name": 5, "x": 4, "y": 3},
    {"name": 5, "x": 5, "y": 3},
    {"name": 5, "x": 6, "y": 3},
    {"name": 1, "x": 6, "y": 5}
  ],
  "goal": 2,
  "target_cells": [
    {"name": 5, "x": 5, "y": 2}
  ]
}
```

This layout uses goal `BREAK_TARGETS` (`2`): the obelisk at `(5, 2)` must be destroyed.

---

## Reward Resources

`ExpeditionRewardData` (`_scr_expedition_reward.gd`):

| Field | Type | Description |
|-------|------|-------------|
| `wood` | `PackedInt64Array` | Wood granted per level; index `level - 1` |

`ExpeditionManager.apply_reward` reads the array entry for the completed level. Expand this Resource when adding currencies or unlocks.

---

## Authoring

Use the expedition editor scene (`features/expeditions/expedition_editor/`):

1. Set `type`, `goal`, and `level` exports on the root node.
2. Paint cells on the grid (same APIs as `CellManager`).
3. Press the **editor_save** InputMap action to write JSON next to this README.

Do not hand-edit enum integers without checking `CellManager.Names` / `ExpeditionManager.Goals` in code.
