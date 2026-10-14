# Phase 1 spatial build

Status: implementation prepared; not executed in Godot or manually validated. Independent from the circuit tests and from earlier scenes.

Open scenes/prototypes/phase1_spatial_greybox.tscn and press F6. Click to capture the mouse; WASD moves relative to the camera; Space jumps. Escape releases the mouse, then Escape returns to the menu. E unlocks the shortcut door only from the cabin side.

**Review views.** F4 toggles a top-down view of the whole complex and F5 a side cut seen from the south; both fade every wall so the layout and the four levels can be read, and pressing the same key again returns to Elena. Use them for the captures that review geometry.

The scene builds the six-room, four-level complex described in FASE1_ROOM_COMPLEX.md (data in scripts/prototypes/phase1_layout.gd). That document supersedes the single-bay plan of FASE1_GREYBOX_SPEC.md for this build and is itself pending design and script validation, so a comparison against the older plan will not match.

Checks (all geometry only, headless-friendly):

- tests/test_phase1_layout.tscn: rooms, stairs, slopes, openings and reachability of the layout data.
- tests/test_phase1_dressing.tscn: dynamic parts exist; no dressing collider blocks a stair, a doorway or its landing.
- tests/test_phase1_navigation.tscn: in every room, with the dressing colliders in place, the spawn point and every opening are mutually reachable on a 0.25 m grid with Elena's clearance, and every clue or control position has reachable floor within 1.6 m.

## Dressing (block 1 of FASE1_GRAND_DESIGN.md)

scripts/prototypes/phase1_dressing.gd dresses every room with the art team's materials and the batching technique of the test room dressing. The rig housing in the hall is deliberately low and compact (5 x 4 m, 2 m high) so it forces a detour without hiding the hall from the camera; the default camera elevation was raised to about 31 degrees for the same reason. The Column rings, the indicator strips and the archive screen are kept as separate nodes for the circuit states of a later block and are dim and static for now. The machine is not wired to the circuit: its behaviour stays blocked until the logic is connected and validated on its own.

## Not in this build

Elena uses the animations embedded in her model; the procedural pose layer is disabled in this scene. Walk playback speed follows ground speed and needs tuning against the real stride. No crouch, climb, circuit interaction, clue objects, archive record, pursuit, extraction, containment or save integration. The lift is not installed (a known limit of the prototype, marked on the floor of the pump room). Falling below -8 m restores the last room's safe point. Performance on the target GPU is not measured: the scene has ten omni lights and large single-mesh floors, which the Compatibility renderer pays for.

Manual route: entry -> hall -> south stairs to the pit and back -> east stairs to the pump room -> north stairs to the catwalk -> west along the catwalk to the cabin -> unlock the shortcut -> descend to the entry. Record Godot version, commit, renderer, resolution and input device, plus frame time, blocked views, falls and unclear destinations.
