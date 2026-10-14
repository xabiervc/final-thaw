# Phase 1 — Room complex (six rooms, four levels)

Status: layout proposal and first build, not executed in Godot and not validated by play. Supersedes the single-bay plan of FASE1_GREYBOX_SPEC.md **for this build only**; the earlier documents stay as design history. Logic remains in FASE1_LOGIC_CONTRACT.md and is not connected to this scene yet.

## Why

A single bay with a pit and a catwalk reads as one screen. The aim is a place with several rooms at different heights, where going up or down changes what you can see and do, and the way back is learned from the way in.

## Rooms and levels

| Room | Level | Role in the investigation |
|---|---|---|
| Entry vestibule | 0 m | Arrival. Its north stairs lead to a closed door above (the shortcut seen from below). |
| Test hall | 0 m | Central hub with the machine. Three exits: west to the entry, south stairs down to the pit, east stairs up to the pump room. Its north wall is the parapet under the catwalk. |
| Service pit | -2 m | Schematic, tampered bridge and maintenance switch positions. Reached only by its own stairs. |
| Pump room | +1.5 m | Transit and pause. Future lift slot. Rest of the route up. |
| Upper catwalk | +3 m | Selector, isolator and indicators positions, looking down over the test hall. Open rail on its south side. |
| Archive cabin | +3 m | Archive terminal. Its south door opens the shortcut stairs down to the entry. |

Route up: entry -> hall -> east stairs -> pump room -> north stairs -> catwalk -> cabin. Route down: the shortcut, unlockable only from the cabin, returns to the entry. The cabin never depends on the shortcut (checked by the layout test).

## Geometry

Plan data and rules live in scripts/prototypes/phase1_layout.gd. Stairs S1 (hall to pit, 18.4 deg), S2 (hall to pump, 14.0 deg), S3 (catwalk to pump, 14.0 deg) and S4 (shortcut, 23.2 deg) are 2 to 3 m wide. Walkable slope limit is 30 deg. Rooms and stairs do not overlap in plan. Walls of a shared boundary are built once, by the owning room.

## Reuse of the art team's work

Materials come from FacilityMaterials (walls, bulkhead, floor, grate, steel, safety paint), the HUD is prompt_hud.gd (objective card, key-cap prompt, banner, zone status), walls between the camera and Elena fade through the shared wall shader's dither parameter, and Elena uses the animations embedded in her model (idle, walk, jump, fall, land) with the procedural pose layer disabled. Not reused yet: the synthesized audio, the line-of-sight interaction manager and the scanner, which need the clue objects to exist first.

## Not in this build

Circuit logic, clues as objects, archive consultation or extraction, pursuit, containment, crouch, climb, the lift, final lighting. Signs mark the future clue and control positions only.

## What must be validated by playing

Whether each level change feels distinct, whether the hall reads as a hub, whether the catwalk view down into the hall helps orientation, whether stairs and camera are comfortable, whether the dither fade hides walls without hiding information, and whether the walk speed matches the animation cycle. Record Godot version, commit, renderer, resolution and input device.
