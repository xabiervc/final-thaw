# Phase 1 spatial build

Status: implementation prepared; not executed in Godot or manually validated. Independent from the circuit tests and from earlier scenes.

Open scenes/prototypes/phase1_spatial_greybox.tscn and press F6. Click to capture the mouse; WASD moves relative to the camera; Space jumps. Escape releases the mouse, then Escape returns to the menu. E unlocks the shortcut door only from the cabin side.

The scene builds the six-room, four-level complex described in FASE1_ROOM_COMPLEX.md (data in scripts/prototypes/phase1_layout.gd). Run tests/test_phase1_layout.tscn for the layout checks and tests/test_phase1_dressing.tscn for the dressing checks (both pure geometry).

## Dressing (block 1 of FASE1_GRAND_DESIGN.md)

scripts/prototypes/phase1_dressing.gd dresses every room with the art team's materials and the batching technique of the test room dressing: the rig housing and the Column in the hall, lockers, evacuation plan and bench in the entry, the schematic board, tampered bridge, maintenance pedestal, pipes and pump in the pit, the warming station, drums, gauge and marked lift slot in the pump room, consoles and indicator strips on the catwalk, and the archive desk and screen in the cabin. Floors carry standing meltwater through the floor shader. Position signs are shown only for the room the player is in.

The Column rings, the indicator strips and the archive screen are kept as separate nodes: they are the hook for the circuit states of the next block and are dim and static for now. Colliders added by the dressing stand only in dead space; the dressing test checks they never block a stair, a doorway or the landing in front of them.

## Not in this build

Elena uses the animations embedded in her model; the procedural pose layer is disabled in this scene. Walk playback speed follows ground speed and needs tuning against the real stride. No crouch, climb, circuit interaction, clue objects, archive record, pursuit, extraction, containment or save integration. The lift is not installed. Falling below -8 m restores the last room's safe point. Performance on the target GPU is not measured: the scene has ten omni lights and large single-mesh floors, which the Compatibility renderer pays for.

Manual route: entry -> hall -> south stairs to the pit and back -> east stairs to the pump room -> north stairs to the catwalk -> west along the catwalk to the cabin -> unlock the shortcut -> descend to the entry. Record Godot version, commit, renderer, resolution and input device, plus frame time, blocked views, falls and unclear destinations.
